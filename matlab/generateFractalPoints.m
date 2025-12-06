function pts = generateFractalPoints(a, b, g, n)
%GENERATEFRACTALPOINTS Returns polyline vertices for a replacement fractal.
%   PTS = GENERATEFRACTALPOINTS(A, B, G, N) recursively replaces segment
%   [A, B] with the generator polygon G for N levels and returns the full
%   list of vertices as complex numbers.
%
%   Inputs:
%       a, b - complex endpoints of the initiator segment
%       g    - row vector of generator vertices (g(1)=0, g(end)=1)
%       n    - recursion depth (non-negative integer)
%
%   Outputs:
%       pts  - row vector of complex vertices describing the polyline
%
%   Example:
%       g = [0, 1/3, 1/2 + 1i*sqrt(3)/6, 2/3, 1];
%       pts = generateFractalPoints(0, 1, g, 3);
%       plot(real(pts), imag(pts), 'k-'); axis equal;

if n == 0
    pts = [a, b];
    return;
end

% Map generator vertices
P = a + (b - a) .* g;

% Recursively build points for each sub-segment
pts = complex([]);
for k = 1:numel(P) - 1
    subPts = generateFractalPoints(P(k), P(k + 1), g, n - 1);
    if k > 1
        % Avoid duplicating the starting vertex of subsequent segments
        subPts = subPts(2:end);
    end
    pts = [pts, subPts]; %#ok<AGROW>
end
end
