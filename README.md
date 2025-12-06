# Codex-Workspace

Replacement-type fractals in MATLAB: start from a small generator formula and
watch it bloom into intricate curves with colour and composable rules. This
project is deliberately wordy and beginner-friendly—follow the commented
examples even if you have almost no coding experience.

## What you get
- **Drawing helpers**: `drawFractalSegment`, `drawColoredFractal`,
  `generateFractalPoints`, `generateFractalImage`, `renderFractal`.
- **Generator toys**: `composeGenerators` to combine shapes, plus a heavily
  commented `fractalPlayground` script with ready-to-run examples.
- **(Optional) fitting tools**: `fitReplacementFractal` and friends automate
  the photo→skeleton→generator workflow, but you can ignore them if you only
  want to build new curves.
- **Quick demo**: `demoKoch` draws the classic Koch curve in a few lines.

## Zero-to-fractal in 5 minutes (no coding background required)
1. Open MATLAB and add the `matlab` folder to your path (Home → Set Path → Add
   Folder).
2. Run `fractalPlayground` from the Command Window. Each section is labelled:
   - Starts with the Koch curve.
   - Bends the generator into smooth ribbons.
   - Composes generators to add texture.
   - Plays with colour palettes and line widths.
   - Wraps a generator around a triangle to make a snowflake.
3. Change a few numbers in the generator vectors (they are just `real + imag*i`
   coordinates). Re-run a section by selecting it and pressing **F9**.
4. Save your favourite generator; the script already writes
   `myFavouriteGenerator.mat` for you.

## Building more intricate replacement fractals
Use these simple tricks to grow complexity from a humble formula:

- **Add a couple more bends**: a generator with 5–7 vertices already makes a
  dramatic difference. Keep the first value `0` and the last `1`; sprinkle
  small imaginary parts for gentle curves.
- **Compose generators**: let an outer generator define the big silhouette and
  an inner generator add fine wiggles. Call `composeGenerators(outer, inner)`
  to get a denser rule without hand-crafting dozens of points.
- **Wrap around a loop**: draw the same generator along each side of a polygon
  (triangle, square, hexagon) to get snowflakes or lace-like borders.
- **Colour by depth**: use `drawColoredFractal` to tint each recursion level.
  Try different colormaps (`hot`, `winter`, `parula`) and line-width fades to
  highlight layer-by-layer detail.
- **Combine compositions**: nothing stops you from composing again: e.g.
  `g_dense = composeGenerators(composeGenerators(outer, inner1), inner2);`
  then render at a lower depth for a textured but not overwhelming curve.

## Key functions (plain-English notes)
- `drawFractalSegment(a, b, g, n)`: the minimalist renderer. Give it complex
  endpoints `a`/`b`, a generator `g` (start 0, end 1), and a depth `n`.
- `drawColoredFractal(...)`: same idea but with colour and tapered line widths
  so you can see the recursion levels.
- `composeGenerators(outer, inner)`: glues an "inner" generator onto every
  segment of the outer one, returning a single, more detailed generator.
- `generateFractalPoints(...)`: returns the polyline vertices if you want to
  post-process or export them.
- `generateFractalImage(...)`: turns a generator and depth into a binary image
  for quick previews.
- `fractalPlayground`: open this script and follow the comments; it is the
  friendliest place to start experimenting.
- `fitReplacementFractal(...)`: advanced/optional. Given an image, it extracts
  a skeleton curve, picks endpoints, simplifies to a generator, and can refine
  it with a small optimisation step. Useful if you want to mimic a natural
  pattern, but not needed for pure generation.

## Suggested first edits for new users
- In `fractalPlayground.m`, tweak the numbers in `g_ribbon` or `g_outer` and
  re-run just that section (highlight → F9). Move points up by adding `0.1i`,
  down with `-0.1i`, left/right by adjusting the real part.
- Swap the colormap name passed to `drawColoredFractal`, e.g. `winter`, `autumn`,
  `copper`, or supply your own `N+1 x 3` RGB matrix.
- Compose different pairs of generators to see how the overall shape and the
  fine detail interact.

## Automating from a photo (optional)
If you do want the automated pipeline, try:

```matlab
result = fitReplacementFractal('leaf.jpg', 4);
imshowpair(result.mask, renderFractal(result.model, size(result.mask)), 'montage');
```

`fitReplacementFractal` uses Canny edges, skeletonisation, endpoint search,
Douglas–Peucker simplification, and optional optimisation. Open the function to
read the step-by-step comments if you are curious.

## Troubleshooting quick hits
- Jagged/overwhelming curves? Lower the recursion depth `n` or simplify your
  generator (fewer vertices).
- Fractal flies off the canvas? Keep generator values roughly within the
  rectangle spanning `0` and `1` in the complex plane.
- Colours look flat? Increase `baseLineWidth`, pick a brighter colormap, or
  set `fadeFactor` closer to `1` so deeper levels stay thick.
