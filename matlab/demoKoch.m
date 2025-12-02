%DEMOKOCH Quick demonstration of the replacement fractal utilities.
%   Draws a Koch-like curve using DRAWFRACTALSEGMENT and generates a binary
%   image with GENERATEFRACTALIMAGE.

% Define classic Koch generator in the unit segment
g_koch = [0, 1/3, 1/2 + 1i * sqrt(3) / 6, 2/3, 1];
depth = 5;

figure; axis equal off; hold on;
drawFractalSegment(0, 1, g_koch, depth);
title(sprintf('Koch curve, depth %d', depth));

imgSize = [600, 600];
BW = generateFractalImage(g_koch, depth, imgSize);

figure; imshow(BW);
title('Binary rendering via generateFractalImage');
