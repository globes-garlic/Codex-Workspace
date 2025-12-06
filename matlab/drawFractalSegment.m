function drawFractalSegment(a, b, g, n, ax)
%DRAWFRACTALSEGMENT Recursively draws a replacement-type fractal segment.
%   DRAWFRACTALSEGMENT(A, B, G, N) draws the segment from complex point A to
%   B using the generator polygon G at recursion depth N.
%
%   DRAWFRACTALSEGMENT(..., AX) plots into the provided axes handle.
%
%   Inputs:
%       a, b - complex numbers representing the segment endpoints
%       g    - row vector of complex generator vertices, with g(1)=0 and
%              g(end)=1 defining the standardised segment [0, 1]
%       n    - non-negative recursion depth
%       ax   - (optional) handle to target axes
%
%   Example:
%       g = [0, 1/3, 1/2 + 1i*sqrt(3)/6, 2/3, 1];
%       figure; axis equal off; hold on;
%       drawFractalSegment(0, 1, g, 4);
%
%   See also GENERATEFRACTALPOINTS.

if nargin < 5 || isempty(ax)
    ax = gca;
end

if n == 0
    plot(ax, [real(a), real(b)], [imag(a), imag(b)], 'k-');
    return;
end

% Map generator vertices from [0, 1] to [a, b]
P = a + (b - a) .* g;

% Recursively draw each sub-segment
for k = 1:numel(P) - 1
    drawFractalSegment(P(k), P(k + 1), g, n - 1, ax);
end
end
