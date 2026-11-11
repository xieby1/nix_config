# Why Snacks image rendering uses Chromium

Some draw.io SVGs use HTML for their labels.
Firefox displays those labels correctly, but the usual ImageMagick SVG renderers can display a shortened fallback instead.
We use headless Chromium to render the existing SVGs faithfully while keeping Snacks' ImageMagick conversion pipeline.

## The original failure

In the Nanhu architecture diagram, `Instruction` and `Uncache` should appear on separate lines.
Snacks showed `Instruction...` instead, with different text sizing.
The intended RGB color negation was unrelated to the missing text.

Draw.io can export a label in this form:

```xml
<switch>
  <foreignObject requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"
                 width="160" height="100">
    <div xmlns="http://www.w3.org/1999/xhtml">Instruction<br/>Uncache</div>
  </foreignObject>
  <text x="80" y="50">Instruction...</text>
</switch>
```

A browser renders the HTML inside `foreignObject`, including its line breaks and formatting.
A renderer that does not support that content selects the fallback `text` element.
The ellipsis is literally present in the SVG; changing resolution cannot restore the missing label.

The local reproduction confirmed this with ImageMagick using Inkscape, and with ImageMagick explicitly using librsvg: both displayed `Instruction...`.
Headless Chromium displayed both complete lines.
Draw.io documents the same issue in [Why text in exported SVG images may not display correctly](https://www.drawio.com/doc/faq/svg-export-text-problems).

## Why this integration

Snacks converts non-PNG images with ImageMagick.
Its `convert.magick` settings configure arguments; they do not select an arbitrary converter executable.
ImageMagick already has an external SVG decoder hook, `svg:decode`, normally used to invoke Inkscape.
Replacing that delegate keeps the integration at the existing renderer boundary.

The resulting flow is:

```text
Snacks conversion and cache
  → ImageMagick reads the SVG
    → svg:decode invokes the Chromium helper
    ← Chromium writes a PNG directly to the delegate output
  → ImageMagick applies the configured RGB negation and writes metadata
  → Snacks displays the cached PNG using the Kitty Graphics Protocol
```

[config.nix](config.nix) packages the helper and delegate file with explicit Nix paths to Python, Chromium, and ImageMagick.
It adds the delegate directory to `MAGICK_CONFIGURE_PATH` in the Neovim wrapper.
This affects Neovim and its child processes; it does not change the desktop's global ImageMagick configuration.
The configuration continues to use the packaged Snacks plugin without a source patch or a browser automation library.

[lua.nix](lua.nix) retains the existing density and dark-background RGB negation settings.
It uses the `snacks/image-chromium` cache directory so PNGs produced by the old renderer are not reused.
The old cache is left intact.

## What the helper preserves

[svg/main.py](svg/main.py) asks ImageMagick's explicit `RSVG:` reader for the canvas dimensions at 96 DPI.
This reader measures the SVG without recursively calling our custom delegate.
Chromium uses those dimensions and a device scale factor of the requested density divided by 96.
The delegate's background color and opacity are passed through to Chromium as well.

The helper resolves ImageMagick's temporary symlink and opens the original `.svg` file whenever possible.
This preserves relative image references without changing the source document.
Snacks downloads remote images to `.data` cache files rather than preserving a `.svg` extension, so those inputs need a temporary `.svg` copy.
For that case, the helper resolves `href`, `xlink:href`, and HTML `src` attributes against the original file location, including inherited `xml:base` values.
It does not rewrite relative CSS `url(...)` references or recover the original remote URL from a downloaded cache file.

Each conversion uses a temporary Chromium profile, keeps the browser sandbox enabled, and checks subprocess failures with timeouts.
Temporary files and the profile are removed when the helper exits.
Chromium writes directly to ImageMagick's requested output path.
An additional crop and PNG rewrite was removed after the regression checks and a pixel comparison showed it was unnecessary.

## Alternatives and costs

For diagrams we author, draw.io's **Text → Advanced → Convert Labels to SVG** is the most portable solution.
Disabling **Formatted Text** and **Word Wrap**, or exporting through PDF, are other documented options.
Those approaches require re-exporting source diagrams; the delegate also works with existing diagrams from other repositories.

Installing Inkscape or increasing `-density` did not fix this HTML-label failure.
Using Chromium adds a browser dependency and startup cost on a cache miss; the initial Nanhu conversion took approximately two seconds on the tested machine.
Snacks reuses the resulting cached PNG on subsequent conversions.
The displayed image is still rasterized, so sharpness depends on the configured density.
Ordinary raster and PDF conversion continue through ImageMagick.

## Verification

From the repository root, build the delegate and run its integration checks:

```sh
svg_delegates=$(nix-build --no-out-link -E '
  let
    pkgs = import <nixpkgs> {};
    module = import ./usr/cli/basic/nvim/snacks/image/config.nix { inherit pkgs; };
  in pkgs.runCommand "snacks-image-delegates" {
    delegatePath = builtins.elemAt module.programs.neovim.extraWrapperArgs 3;
  } "ln -s $delegatePath $out"
')
MAGICK_CONFIGURE_PATH="$svg_delegates" \
  python usr/cli/basic/nvim/snacks/image/svg/test.py
```

[svg/test.py](svg/test.py) checks multiline HTML labels, RGB negation, DPI, small and viewBox-only canvases, physical units, transparency, background color, relative images, downloaded `.data` inputs, and ordinary raster conversion.
These checks use real Chromium and ImageMagick output.
The simplified helper also produced a pixel-identical `6972×7446` negated Nanhu image, and conversion through Snacks itself passed using the built Home Manager Neovim wrapper.

Build and activate the Home Manager configuration normally, then restart Neovim to load the new wrapper and image cache setting.

## Upstream references

- [Draw.io SVG label compatibility and export alternatives](https://www.drawio.com/doc/faq/svg-export-text-problems)
- [Snacks image conversion implementation](https://github.com/folke/snacks.nvim/blob/main/lua/snacks/image/convert.lua)
- [ImageMagick SVG decoder and `svg:decode` invocation](https://github.com/ImageMagick/ImageMagick/blob/main/coders/svg.c)
- [ImageMagick delegate configuration](https://github.com/ImageMagick/ImageMagick/blob/main/config/delegates.xml.in)
- [Chromium headless mode](https://developer.chrome.com/docs/chromium/headless)
