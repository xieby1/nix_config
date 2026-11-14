"""Run with MAGICK_CONFIGURE_PATH pointing at the built delegate directory."""

import os
from pathlib import Path
import subprocess
import tempfile


def magick(*args):
    return subprocess.check_output(["magick", *map(str, args)], timeout=45)


def pixels(path):
    data = magick(path, "-depth", "8", "RGBA:-")
    return list(zip(*[iter(data)] * 4))


def svg(path, attrs, content):
    path.write_text(f'<svg xmlns="http://www.w3.org/2000/svg" {attrs}>{content}</svg>')


assert os.environ.get("MAGICK_CONFIGURE_PATH"), "Set the built SVG delegate directory"
with tempfile.TemporaryDirectory(prefix="snacks-svg-test-") as tmp:
    tmp = Path(tmp)
    source = tmp / "labels with spaces.svg"
    output = tmp / "render.png"
    svg(source, 'width="160" height="100"', '''
      <switch>
        <foreignObject width="160" height="100"
          requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility">
          <div xmlns="http://www.w3.org/1999/xhtml"
            style="font:24px/32px sans-serif">
            <span style="color:red">Tilelink</span><br/>
            <span style="color:blue">Node</span>
          </div>
        </foreignObject>
        <text x="0" y="20" fill="green">Fallback...</text>
      </switch>''')
    magick("-density", "192", source, output)
    assert magick("identify", "-format", "%w %h %x %y", output) == b"320 200 192 192"
    image = pixels(output)
    assert image.count((255, 0, 0, 255)) > 50, "First HTML line is missing"
    assert image[320 * 60:].count((0, 0, 255, 255)) > 50, "Second HTML line is missing"
    magick("-density", "192", source, "-channel", "RGB", "-negate", output)
    assert pixels(output).count((255, 255, 0, 255)) > 50, "RGB negation was lost"

    # ViewBox-only and physical-unit sizing also exercise small Chromium viewports.
    for attrs, expected in [
        ('viewBox="0 0 40 20"', b"40 20"),
        ('width="1in" height="0.5in" viewBox="0 0 40 20"', b"96 48"),
    ]:
        svg(source, attrs, '<rect width="20" height="20" fill="red"/>'
            '<rect x="20" width="20" height="20" fill="blue"/>')
        magick("-density", "96", "-background", "none", source, output)
        assert magick("identify", "-format", "%w %h", output) == expected
        assert pixels(output)[0] == (255, 0, 0, 255)
        assert pixels(output)[-1] == (0, 0, 255, 255), "SVG was clipped or scaled incorrectly"

    svg(source, 'width="80" height="60"', '<rect width="10" height="10" fill="red"/>')
    magick("-density", "96", "-background", "none", source, output)
    assert pixels(output)[-1][3] == 0, "Transparent background was lost"
    magick("-density", "96", "-background", "#00ff00", source, output)
    assert pixels(output)[-1] == (0, 255, 0, 255), "Background color was lost"

    magick("-size", "20x20", "xc:blue", tmp / "relative.png")
    svg(source, 'width="80" height="60"', '<image href="relative.png" width="20" height="20"/>')
    magick("-density", "96", source, output)
    assert pixels(output)[0] == (0, 0, 255, 255), "Relative image URL was lost"
    extensionless = tmp / "download.data"
    extensionless.write_bytes(source.read_bytes())
    magick("-density", "96", f"SVG:{extensionless}", output)
    assert pixels(output)[0] == (0, 0, 255, 255), "Extensionless SVG resources were lost"

    # Ordinary raster conversions must still use ImageMagick normally.
    magick("-size", "20x10", "xc:red", tmp / "raster.jpg")
    magick(tmp / "raster.jpg", output)
    assert magick("identify", "-format", "%w %h", output) == b"20 10"

print("SVG labels, negation, dimensions, alpha, relative URLs, and raster conversion passed")
