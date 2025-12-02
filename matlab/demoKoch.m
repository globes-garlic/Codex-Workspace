%DEMOKOCH Quick, heavily-commented demonstration of replacement fractals.
% Run this file (press F5) to see two renderings of the classic Koch generator:
% 1) Plain black-and-white using DRAWFRACTALSEGMENT
% 2) Colour-coded layers using DRAWCOLOREDFRACTAL
%
% The generator g_koch lists the bending points along a straight segment from
% 0 to 1 in the complex plane. You can tweak the numbers and re-run to see how
% the curve changes.

g_koch = [0, 1/3, 1/2 + 1i * sqrt(3) / 6, 2/3, 1];
depth = 5; % try lowering to 3 for a simpler shape

% --- Plain rendering ------------------------------------------------------
figure('Name', 'Plain Koch'); axis equal off; hold on;
drawFractalSegment(0, 1, g_koch, depth);
title(sprintf('Koch curve, depth %d (plain)', depth));

% --- Colourful rendering --------------------------------------------------
figure('Name', 'Coloured Koch'); axis equal off; hold on;
drawColoredFractal(0, 1, g_koch, depth, struct('colourMap', 'winter'));
title('Same generator, coloured by recursion level');

% --- Binary image preview (useful for quick export) -----------------------
imgSize = [600, 600];
BW = generateFractalImage(g_koch, depth, imgSize);
figure('Name', 'Binary image'); imshow(BW);
title('Binary rendering via generateFractalImage');
