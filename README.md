# Codex-Workspace

MATLAB utilities for experimenting with replacement-type fractal curves.

## Contents
- `matlab/drawFractalSegment.m`: recursive renderer for replacement fractal segments.
- `matlab/generateFractalPoints.m`: returns polyline vertices for a generator at a given depth.
- `matlab/generateFractalImage.m`: rasterises a fractal into a binary image.
- `matlab/renderFractal.m`: convenience wrapper to render saved fractal models.
- `matlab/generatorError.m`: objective function for refining generators against a binary mask.
- `matlab/optimizeGeneratorVertices.m`: fminsearch-based refinement of generator vertices.
- `matlab/demoKoch.m`: simple example using a Koch-style generator.

## Usage
1. Open MATLAB and add the `matlab` folder to your path.
2. Run `demoKoch` for a quick demonstration of the drawing and rendering pipeline.
3. Build your own generator `g` (with endpoints `0` and `1`), choose recursion depth `n`,
   and call `drawFractalSegment`, `generateFractalPoints`, or `generateFractalImage` to
   explore different curves.
4. When fitting to a skeletonised mask, start with manual vertices, then call
   `optimizeGeneratorVertices` to refine the intermediate points.
