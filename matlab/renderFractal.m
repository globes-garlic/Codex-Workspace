function BW = renderFractal(fractalModel, imgSize)
%RENDERFRACTAL Render a stored fractal model to a binary image.
%   BW = RENDERFRACTAL(FRACTALMODEL, IMGSIZE) draws the fractal defined by
%   FRACTALMODEL (with fields a, b, g, n) to a binary image of size
%   IMGSIZE = [height, width].
%
%   Example:
%       model.a = 0; model.b = 1; model.g = [0 1/3 1/2+1i*sqrt(3)/6 2/3 1];
%       model.n = 5;
%       BW = renderFractal(model, [512 512]);
%       imshow(BW);

arguments
    fractalModel struct
    imgSize (1,2) double {mustBePositive}
end

a = fractalModel.a;
b = fractalModel.b;
g = fractalModel.g;
n = fractalModel.n;

BW = generateFractalImage(g, n, imgSize, a, b);
end
