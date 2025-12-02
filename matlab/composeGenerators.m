function gOut = composeGenerators(gOuter, gInner)
%COMPOSEGENERATORS Combine two generators into a single, more intricate rule.
%   GOUT = COMPOSEGENERATORS(GOUTER, GINNER) applies the inner generator
%   once to every segment of the outer generator and stitches the result into
%   a new generator. The endpoints stay fixed at 0 and 1, but the middle
%   vertices become more detailed. Use this to grow complexity from simple
%   building blocks without designing a huge generator by hand.
%
%   The idea: if GOUTER makes the overall silhouette you like, and GINNER
%   adds texture, their composition gives a denser pattern that still follows
%   the big outline. You can chain this repeatedly for multi-scale detail.
%
%   Example:
%       g_base = [0, 0.4 + 0.1i, 0.7 - 0.15i, 1];
%       g_spice = [0, 0.3i, 1];
%       g_combo = composeGenerators(g_base, g_spice);
%       drawColoredFractal(0, 1, g_combo, 4);
%
%   See also DRAWCOLOREDFRACTAL, DRAWFRACTALSEGMENT.

% Guardrails for new users
if gOuter(1) ~= 0 || gOuter(end) ~= 1 || gInner(1) ~= 0 || gInner(end) ~= 1
    error('Both generators must start at 0 and end at 1.');
end

segments = numel(gOuter) - 1;
points = complex([]);

for k = 1:segments
    a = gOuter(k);
    b = gOuter(k + 1);

    mapped = a + (b - a) .* gInner; % place inner generator onto outer segment

    if k > 1
        mapped = mapped(2:end); % avoid duplicate vertices when stitching
    end

    points = [points, mapped]; %#ok<AGROW>
end

gOut = points;
end
