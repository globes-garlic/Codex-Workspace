function gOpt = optimizeGeneratorVertices(initialG, mask, a, b, n, options)
%OPTIMIZEGENERATORVERTICES Refines generator vertices to fit a skeleton mask.
%   GOPT = OPTIMIZEGENERATORVERTICES(INITIALG, MASK, A, B, N) refines the
%   intermediate vertices of INITIALG (keeping the endpoints fixed at 0 and
%   1) to better align the depth-N fractal with the binary MASK. A and B are
%   complex endpoints of the initiator segment.
%
%   GOPT = ... (..., OPTIONS) forwards optimisation options to FMINSEARCH.
%
%   The optimisation minimises GENERATORERROR starting from the manually
%   selected generator.

arguments
    initialG (1,:) double
    mask logical
    a (1,1) double
    b (1,1) double
    n (1,1) double {mustBeInteger, mustBeNonnegative}
    options struct = struct()
end

if numel(initialG) < 3
    gOpt = initialG;
    return;
end

params0 = [real(initialG(2:end-1)), imag(initialG(2:end-1))];
obj = @(p) generatorError(p, mask, a, b, n);

if isempty(fieldnames(options))
    options = optimset('Display', 'off');
end

paramsOpt = fminsearch(obj, params0, options);
K = numel(paramsOpt) / 2 + 2;
gOpt = zeros(1, K);
gOpt(1) = 0;
gOpt(end) = 1;
gOpt(2:end-1) = paramsOpt(1:K-2) + 1i * paramsOpt(K-1:end);
end
