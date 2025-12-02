%FRACTALPLAYGROUND Gentle, commented tour for creating richer fractals.
% This script is written for readers who have little to no coding experience.
% Every block is short and labelled. You can run the whole file or just one
% section at a time by selecting it in the MATLAB editor and pressing F9.
%
% The goal: start from simple generators, then layer in complexity via
% composition and colouring so you can grow "koch-like" curves into more
% intricate designs.
%
% -------------------------------------------------------------------------
% 0) Housekeeping: make the plots look tidy
% -------------------------------------------------------------------------
close all; clc;

% -------------------------------------------------------------------------
% 1) Classic Koch-style starter
% -------------------------------------------------------------------------
newCanvas('Classic Koch');
g_koch = [0, 1/3, 1/2 + 1i * sqrt(3) / 6, 2/3, 1];
depth = 5;
drawColoredFractal(0, 1, g_koch, depth);
title('Classic Koch generator, coloured by recursion level');

% -------------------------------------------------------------------------
% 2) Adding gentle curvature (bending the generator)
% -------------------------------------------------------------------------
newCanvas('S-curve base');
% A few bends give a flowing, ribbon-like curve.
g_ribbon = [0, 0.25 + 0.05i, 0.5 - 0.15i, 0.75 + 0.1i, 1];
drawColoredFractal(0, 1, g_ribbon, depth, struct('colourMap', 'winter'));
title('Smooth ribbon generator with cool colours');

% -------------------------------------------------------------------------
% 3) Compose generators to add texture on top of a shape
% -------------------------------------------------------------------------
newCanvas('Composed generator');
% Outer generator controls the big silhouette, inner adds wiggles.
g_outer = [0, 0.4 + 0.12i, 0.7 - 0.2i, 1];
g_inner = [0, 0.25i, -0.1i, 0.4i, 1];
g_composed = composeGenerators(g_outer, g_inner);
% Slightly lower depth because the generator itself is more detailed.
drawColoredFractal(0, 1, g_composed, 4, struct('colourMap', 'autumn'));
title({'Generator composition: outer silhouette + inner texture', ...
       'Try composing again for even denser detail'});

% -------------------------------------------------------------------------
% 4) Shift colours and line widths to emphasise layers
% -------------------------------------------------------------------------
newCanvas('Warm fade');
opts.colourMap = hot(depth + 1); % warm palette
opts.baseLineWidth = 3;          % thick outlines
opts.fadeFactor = 0.5;           % quickly taper line widths down the levels
% Reuse the composed generator from above
drawColoredFractal(0, 1, g_composed, depth, opts);
title({'Colour and line-width control', 'Warm palette with tapered strokes'});

% -------------------------------------------------------------------------
% 5) Create a "snowflake" by wrapping the curve around a triangle
% -------------------------------------------------------------------------
newCanvas('Wrapped snowflake');
% Build an equilateral triangle and draw the fractal on each side.
triangle = [0, 1, 0.5 + 1i * sqrt(3) / 2, 0];
for ii = 1:numel(triangle) - 1
    drawColoredFractal(triangle(ii), triangle(ii + 1), g_ribbon, 4, ...
                       struct('colourMap', 'parula'));
end
title({'Snowflake-style tiling', 'Wrap your favourite generator around a loop'});

% -------------------------------------------------------------------------
% 6) Save your favourite generator for later reuse
% -------------------------------------------------------------------------
save('myFavouriteGenerator.mat', 'g_composed', 'g_ribbon', 'g_koch');
% You can load this file next time instead of retyping the vectors.

% -------------------------------------------------------------------------
% Local helper functions (kept tiny and readable)
% -------------------------------------------------------------------------
function newCanvas(name)
    figure('Name', name); axis equal off; hold on;
end
