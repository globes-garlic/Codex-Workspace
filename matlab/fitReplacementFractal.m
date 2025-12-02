function result = fitReplacementFractal(imageInput, n, options)
%FITREPLACEMENTFRACTAL Automate fitting a replacement-type fractal to an image.
%   RESULT = FITREPLACEMENTFRACTAL(IMAGEINPUT, N) extracts a skeleton curve
%   from IMAGEINPUT (filepath or array), fits a generator, and returns a
%   struct with fields a, b, g, and n. The process is fully scripted:
%     1) preprocess -> edges -> skeleton -> largest curve
%     2) trace an ordered polyline along the skeleton
%     3) auto-pick endpoints (farthest pair) and map to [0,1]
%     4) simplify to generator vertices via Douglas-Peucker
%     5) optionally optimise vertices against the mask
%
%   RESULT = FITREPLACEMENTFRACTAL(..., OPTIONS) overrides defaults:
%       options.roiRect           : [x y w h] crop rectangle (skip selection)
%       options.sigma             : Gaussian sigma for smoothing (default 1)
%       options.edgeThresh        : Canny threshold (default [] -> automatic)
%       options.minComponentArea  : remove tiny blobs (default 30 px)
%       options.numTracePoints    : resample count along the skeleton (200)
%       options.maxVertices       : target vertex count for generator (6)
%       options.douglasTolerance  : simplification tolerance (0.01)
%       options.autoOptimize      : run optimise step (true)
%       options.optimizeOptions   : struct passed to FMINSEARCH
%       options.displayFigures    : whether to show intermediate plots (true)
%
%   Note: requires Image Processing Toolbox for bwskel/bwtraceboundary.
%
%   Example:
%       result = fitReplacementFractal('leaf.jpg', 4);
%       Ifrac = renderFractal(result.model, size(result.mask));
%       imshowpair(result.mask, Ifrac, 'montage');
%
%   See README for an overview of the workflow.

arguments
    imageInput
    n (1,1) double {mustBeInteger, mustBeNonnegative}
    options.roiRect (1,4) double = []
    options.sigma (1,1) double = 1
    options.edgeThresh = []
    options.minComponentArea (1,1) double = 30
    options.numTracePoints (1,1) double = 200
    options.maxVertices (1,1) double = 6
    options.douglasTolerance (1,1) double = 0.01
    options.autoOptimize (1,1) logical = true
    options.optimizeOptions struct = struct()
    options.displayFigures (1,1) logical = true
end

% -------------------------------------------------------------------------
% 1) Load and optionally crop
% -------------------------------------------------------------------------
if ischar(imageInput) || isstring(imageInput)
    I = imread(imageInput);
else
    I = imageInput;
end

if size(I, 3) == 3
    Igray = rgb2gray(I);
else
    Igray = I;
end

if isempty(options.roiRect)
    roi = Igray;
else
    roi = imcrop(Igray, options.roiRect);
end

roi = im2double(roi);

% -------------------------------------------------------------------------
% 2) Edge detection and cleanup
% -------------------------------------------------------------------------
roiSmooth = imgaussfilt(roi, options.sigma);
BWedge = edge(roiSmooth, 'canny', options.edgeThresh);
BWclose = bwmorph(BWedge, 'close');
BWclean = bwareaopen(BWclose, options.minComponentArea);

% -------------------------------------------------------------------------
% 3) Skeletonise and keep largest component
% -------------------------------------------------------------------------
BWskel = bwskel(BWclean);
BWlabel = bwlabel(BWskel);
if max(BWlabel(:)) == 0
    error('No skeleton found; adjust preprocessing parameters.');
end
stats = regionprops(BWlabel, 'Area');
[~, idxMax] = max([stats.Area]);
mask = BWlabel == idxMax;

% -------------------------------------------------------------------------
% 4) Trace an ordered polyline along the skeleton
% -------------------------------------------------------------------------
[startR, startC] = find(mask, 1, 'first');
boundary = bwtraceboundary(mask, [startR startC], 'N', 8, Inf, 'clockwise');
if isempty(boundary)
    error('Could not trace skeleton boundary.');
end

H = size(mask, 1);
x = boundary(:, 2);
y = H - boundary(:, 1) + 1; % flip to Cartesian y-up
z = x + 1i * y;

zResampled = resamplePolyline(z, options.numTracePoints);

% -------------------------------------------------------------------------
% 5) Auto-pick endpoints as farthest pair
% -------------------------------------------------------------------------
[a, b] = farthestPair(zResampled);
w = (zResampled - a) ./ (b - a);

% -------------------------------------------------------------------------
% 6) Simplify to generator vertices
% -------------------------------------------------------------------------
wSimple = douglasPeucker(w, options.douglasTolerance);
wSimple = enforceMaxVertices(wSimple, options.maxVertices);
% ensure endpoints exact
wSimple(1) = 0;
wSimple(end) = 1;

% -------------------------------------------------------------------------
% 7) Optional optimisation against mask
% -------------------------------------------------------------------------
gInitial = wSimple.'; % row vector
if options.autoOptimize && numel(gInitial) >= 3
    gOpt = optimizeGeneratorVertices(gInitial, mask, a, b, n, options.optimizeOptions);
else
    gOpt = gInitial;
end

model = struct('a', a, 'b', b, 'g', gOpt, 'n', n);

% -------------------------------------------------------------------------
% 8) Visualisation (optional)
% -------------------------------------------------------------------------
if options.displayFigures
    figure; imshow(mask); title('Largest skeleton component');
    hold on; plot(real(z), H - imag(z) + 1, 'r.', 'MarkerSize', 4);
    hold off;

    figure; plot(real(w), imag(w), 'k-'); hold on;
    plot(real(wSimple), imag(wSimple), 'ro-','LineWidth',1.5);
    axis equal; title('Unit-frame trace and simplified generator');
    legend('Trace','Generator');
    hold off;

    figure; Ifrac = renderFractal(model, size(mask));
    imshowpair(mask, Ifrac, 'montage');
    title('Skeleton (left) vs fitted fractal (right)');
end

result = struct('model', model, ...
                'mask', mask, ...
                'trace', zResampled, ...
                'unitTrace', w, ...
                'generator', gOpt);
end

% -------------------------------------------------------------------------
function zOut = resamplePolyline(z, N)
    if numel(z) <= 2
        zOut = z;
        return;
    end
    d = [0; cumsum(abs(diff(z)))];
    t = linspace(0, d(end), N).';
    zOut = interp1(d, z, t, 'linear');
end

function [p, q] = farthestPair(z)
    D = abs(z - z.');
    D(1:size(D,1)+1:end) = -Inf; % ignore diagonal
    [~, idx] = max(D(:));
    [i, j] = ind2sub(size(D), idx);
    p = z(i);
    q = z(j);
end

function zOut = douglasPeucker(z, epsilon)
    if numel(z) <= 2
        zOut = z(:); return; %#ok<*UNRCH>
    end
    % recursive Douglas-Peucker on complex polyline
    [~, idxMax, distMax] = maxDeviation(z);
    if distMax > epsilon
        left = douglasPeucker(z(1:idxMax), epsilon);
        right = douglasPeucker(z(idxMax:end), epsilon);
        zOut = [left(1:end-1); right];
    else
        zOut = [z(1); z(end)];
    end
end

function [dists, idxMax, distMax] = maxDeviation(z)
    a = z(1); b = z(end);
    if a == b
        dists = abs(z - a);
    else
        v = b - a;
        dists = abs(imag((z - a) ./ v));
        dists = dists * abs(v);
    end
    [distMax, idxMax] = max(dists);
end

function wOut = enforceMaxVertices(w, maxVertices)
    if numel(w) <= maxVertices
        wOut = w(:).';
        return;
    end
    idx = round(linspace(1, numel(w), maxVertices));
    wOut = w(idx);
end
