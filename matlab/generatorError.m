function err = generatorError(params, mask, a, b, n)
%GENERATORERROR Objective for refining generator vertices against a mask.
%   ERR = GENERATORERROR(PARAMS, MASK, A, B, N) constructs a generator
%   polygon with fixed endpoints 0 and 1 using PARAMS as intermediate vertex
%   coordinates (real parts followed by imaginary parts). The fractal
%   defined by [A, B], generator G and depth N is rasterised into MASK's
%   coordinate system, and the error is one minus the fraction of vertices
%   landing on foreground pixels.
%
%   This objective is intended for use with FMINSEARCH or similar solvers.

K = numel(params) / 2 + 2;
if rem(numel(params), 2) ~= 0
    error('Parameter vector must contain real and imaginary parts.');
end

% Reassemble generator
reParts = params(1:K-2);
imParts = params(K-1:end);
g = zeros(1, K);
g(1) = 0;
g(end) = 1;
g(2:end-1) = reParts + 1i * imParts;

% Generate vertices in the original coordinate system
pts = generateFractalPoints(a, b, g, n);
[H, W] = size(mask);

xs = round(real(pts));
ys = H - round(imag(pts));
valid = xs >= 1 & xs <= W & ys >= 1 & ys <= H;
if ~any(valid)
    err = 1; % maximal error if nothing falls on the mask
    return;
end
linIdx = sub2ind(size(mask), ys(valid), xs(valid));
err = 1 - mean(mask(linIdx));
end
