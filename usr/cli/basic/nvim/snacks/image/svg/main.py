"""ImageMagick svg:decode delegate: render HTML labels with Chromium."""

import math
from pathlib import Path
import re
import subprocess
import sys
import tempfile
from urllib.parse import urljoin
import xml.etree.ElementTree as ET


def render(chromium, magick, source, output, density, background, opacity):
    source = Path(source).resolve()
    scale = float(density) / 96
    if not math.isfinite(scale) or scale <= 0:
        raise ValueError(f"Invalid SVG density: {density}")

    # RSVG measures the canvas without invoking this SVG delegate recursively.
    size = subprocess.check_output(
        [magick, "identify", "-density", "96", "-format", "%w %h", f"RSVG:{source}"],
        text=True,
        timeout=30,
    )
    width, height = (int(n) for n in size.split())
    if width <= 0 or height <= 0:
        raise ValueError(f"Invalid SVG dimensions: {size}")

    channels = re.fullmatch(r"rgb\(([\d.]+)%,([\d.]+)%,([\d.]+)%\)", background)
    if channels is None:
        raise ValueError(f"Invalid SVG background: {background}")
    rgba = [round(float(n) * 255 / 100) for n in channels.groups()]
    rgba.append(round(float(opacity) * 255))
    if any(n < 0 or n > 255 for n in rgba):
        raise ValueError("SVG background channels must be between 0 and 255")
    color = "".join(f"{n:02x}" for n in rgba)

    with tempfile.TemporaryDirectory(prefix="snacks-svg-") as tmp:
        tmp = Path(tmp)
        svg = source
        if source.suffix.lower() != ".svg":
            # Chromium needs an SVG extension; resolve resources before relocating it.
            ET.register_namespace("", "http://www.w3.org/2000/svg")
            ET.register_namespace("xhtml", "http://www.w3.org/1999/xhtml")
            tree = ET.parse(source)
            base = "{http://www.w3.org/XML/1998/namespace}base"

            def resolve_urls(element, parent_url):
                url = urljoin(parent_url, element.get(base, ""))
                for attr in ("href", "{http://www.w3.org/1999/xlink}href", "src"):
                    value = element.get(attr)
                    if value and not value.startswith("#"):
                        element.set(attr, urljoin(url, value))
                for child in element:
                    resolve_urls(child, url)

            resolve_urls(tree.getroot(), source.as_uri())
            svg = tmp / "input.svg"
            tree.write(svg, encoding="utf-8", xml_declaration=True)
        subprocess.run(
            [
                chromium,
                "--headless",
                "--disable-gpu",
                "--hide-scrollbars",
                "--no-first-run",
                "--no-default-browser-check",
                f"--force-device-scale-factor={scale}",
                f"--window-size={width},{height}",
                f"--default-background-color={color}",
                f"--screenshot={output}",
                f"--user-data-dir={tmp / 'profile'}",
                svg.as_uri(),
            ],
            check=True,
            capture_output=True,
            timeout=30,
        )


if __name__ == "__main__":
    try:
        render(*sys.argv[1:])
    except subprocess.CalledProcessError as error:
        if error.stderr:
            sys.stderr.buffer.write(error.stderr)
        raise
