function BW = generateFractalImage(g, n, imgSize, a, b)
%GENERATEFRACTALIMAGE Renders a replacement-type fractal to a binary image.
%   BW = GENERATEFRACTALIMAGE(G, N, IMGSIZE) draws the fractal defined by
%   generator G at recursion depth N onto an image of size IMGSIZE
%   ([height, width]). The initiator segment defaults to 0..1 on the real
%   axis.
%
%   BW = GENERATEFRACTALIMAGE(G, N, IMGSIZE, A, B) specifies complex
%   endpoints A and B for the initiator segment.
%
%   Example:
%       g = [0, 1/3, 1/2 + 1i*sqrt(3)/6, 2/3, 1];
%       BW = generateFractalImage(g, 5, [512, 512]);
%       imshow(BW);

if nargin < 4 || isempty(a)
    a = 0;
end
if nargin < 5 || isempty(b)
    b = 1;
end

fig = figure('Visible', 'off', 'Position', [100, 100, imgSize(2), imgSize(1)]);
ax = axes('Parent', fig);
axis(ax, 'equal');
axis(ax, 'off');
hold(ax, 'on');

xlim(ax, [0, imgSize(2)]);
ylim(ax, [0, imgSize(1)]);

% Draw fractal in image coordinate system (y grows downward in image)
% Flip imaginary part to align with image coordinates
scaledA = real(a) + 1i * (imgSize(1) - imag(a));
scaledB = real(b) + 1i * (imgSize(1) - imag(b));

% Shift generator drawing to fit within canvas
plot(ax, NaN, NaN); % force axes to exist

translatedG = g;

% Render
P = scaledA + (scaledB - scaledA) .* translatedG;
for k = 1:numel(P) - 1
    drawFractalSegment(P(k), P(k + 1), translatedG, n, ax);
end

frame = getframe(ax);
img = frame2im(frame);
if size(img, 3) == 3
    img = rgb2gray(img);
end
BW = imbinarize(img);
close(fig);
end
