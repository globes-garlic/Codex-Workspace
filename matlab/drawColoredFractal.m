function drawColoredFractal(a, b, g, n, options)
%DRAWCOLORFRACTAL Draw a replacement fractal with per-level colours.
%   DRAWCOLORFRACTAL(A, B, G, N) draws the fractal defined by generator G
%   between complex endpoints A and B to recursion depth N. Each recursion
%   level is tinted using a simple colour map so you can see how detail is
%   added. This is intentionally verbose and beginner-friendly.
%
%   DRAWCOLORFRACTAL(..., OPTIONS) lets you override defaults:
%       options.ax           : axes handle (defaults to current axes)
%       options.colourMap    : N+1-by-3 RGB matrix or colormap name
%                              (default: parula(N+1))
%       options.baseLineWidth: line width for the top level (default 2)
%       options.fadeFactor   : multiply line width each level (default 0.7)
%
%   The code mirrors DRAWFRACTALSEGMENT but adds colour and line-width
%   variation so you can explore more intricate, layered appearances without
%   changing your generator formula.
%
%   Example:
%       g = [0, 1/3, 1/2 + 1i * sqrt(3)/6, 2/3, 1];
%       figure; axis equal off; hold on;
%       drawColoredFractal(0, 1, g, 5);
%       title('Koch curve with depth-based colouring');
%
%   See also DRAWFRACTALSEGMENT.

arguments
    a
    b
    g
    n (1,1) double {mustBeNonnegative}
    options.ax = []
    options.colourMap = []
    options.baseLineWidth (1,1) double = 2
    options.fadeFactor (1,1) double = 0.7
end

% Prepare axes
if isempty(options.ax)
    ax = gca;
else
    ax = options.ax;
end
hold(ax, 'on');
axis(ax, 'equal');

% Prepare colours: either an explicit matrix or generate from a name
if isempty(options.colourMap)
    colours = parula(n + 1);
elseif ischar(options.colourMap) || isstring(options.colourMap)
    cmapFcn = str2func(options.colourMap);
    colours = cmapFcn(n + 1);
else
    colours = options.colourMap;
end

if size(colours, 1) < n + 1
    error('Colour map needs at least n+1 rows (one per recursion level).');
end

% Nested helper so we can track the current recursion level
    function recurseDraw(p, q, level)
        % Pick colour and line width for this depth level (0 = deepest)
        colour = colours(level + 1, :);
        lw = options.baseLineWidth * (options.fadeFactor ^ (n - level));

        if level == 0
            plot(ax, [real(p), real(q)], [imag(p), imag(q)], '-', ...
                 'Color', colour, 'LineWidth', lw);
            return;
        end

        % Map generator vertices from [0, 1] to [p, q]
        P = p + (q - p) .* g;
        for kk = 1:numel(P) - 1
            recurseDraw(P(kk), P(kk + 1), level - 1);
        end
    end

recurseDraw(a, b, n);
end
