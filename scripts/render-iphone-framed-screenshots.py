#!/usr/bin/env python3

from __future__ import annotations

import argparse
import re
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Render realistic iPhone-framed screenshots.")
    parser.add_argument("--source-dir", required=True, help="Directory containing iPhone PNG screenshots.")
    parser.add_argument("--output-dir", required=True, help="Directory for framed PNG screenshots.")
    return parser.parse_args()


def lerp_color(a: tuple[int, int, int], b: tuple[int, int, int], t: float) -> tuple[int, int, int]:
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def draw_vertical_gradient(image: Image.Image, top: tuple[int, int, int], bottom: tuple[int, int, int]) -> None:
    draw = ImageDraw.Draw(image)
    width, height = image.size
    for y in range(height):
        t = y / max(1, height - 1)
        draw.line([(0, y), (width, y)], fill=lerp_color(top, bottom, t))


def draw_horizontal_gradient(image: Image.Image, left: tuple[int, int, int], right: tuple[int, int, int]) -> None:
    draw = ImageDraw.Draw(image)
    width, height = image.size
    for x in range(width):
        t = x / max(1, width - 1)
        draw.line([(x, 0), (x, height)], fill=lerp_color(left, right, t))


def rounded_mask(size: tuple[int, int], radius: int) -> Image.Image:
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([(0, 0), (size[0], size[1])], radius=radius, fill=255)
    return mask


def natural_sort_key(path: Path) -> tuple[int, str]:
    match = re.search(r"screenshot-(\d+)-", path.name)
    number = int(match.group(1)) if match else 999
    return (number, path.name)


def frame_iphone_screenshot(source: Image.Image) -> Image.Image:
    screen = source.convert("RGBA")
    sw, sh = screen.size

    bezel = max(44, int(sw * 0.055))
    shell = max(10, int(sw * 0.010))
    phone_w = sw + (bezel + shell) * 2
    phone_h = sh + (bezel + shell) * 2

    canvas_pad_x = max(140, int(sw * 0.19))
    canvas_pad_y = max(170, int(sh * 0.09))
    cw = phone_w + canvas_pad_x * 2
    ch = phone_h + canvas_pad_y * 2

    canvas = Image.new("RGB", (cw, ch), (233, 236, 241))
    draw_vertical_gradient(canvas, (246, 248, 252), (223, 228, 236))
    canvas_rgba = canvas.convert("RGBA")

    phone_left = canvas_pad_x
    phone_top = canvas_pad_y
    phone_right = phone_left + phone_w
    phone_bottom = phone_top + phone_h

    # Soft shadow behind hardware body.
    shadow = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_draw.rounded_rectangle(
        [
            (phone_left + int(sw * 0.008), phone_top + int(sh * 0.018)),
            (phone_right + int(sw * 0.008), phone_bottom + int(sh * 0.018)),
        ],
        radius=int(phone_w * 0.14),
        fill=(0, 0, 0, 120),
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=max(18, int(sw * 0.03))))
    canvas_rgba = Image.alpha_composite(canvas_rgba, shadow)

    # Phone body with metallic side-tone.
    body = Image.new("RGBA", (phone_w, phone_h), (0, 0, 0, 0))
    body_base = Image.new("RGB", (phone_w, phone_h), (34, 35, 39))
    draw_horizontal_gradient(body_base, (46, 48, 53), (22, 23, 26))
    body_mask = rounded_mask((phone_w, phone_h), radius=int(phone_w * 0.14))
    body.paste(body_base.convert("RGBA"), (0, 0), body_mask)

    body_overlay = ImageDraw.Draw(body)
    body_overlay.rounded_rectangle(
        [(1, 1), (phone_w - 2, phone_h - 2)],
        radius=int(phone_w * 0.14),
        outline=(170, 174, 182, 140),
        width=max(2, int(sw * 0.003)),
    )
    body_overlay.rounded_rectangle(
        [(shell, shell), (phone_w - shell, phone_h - shell)],
        radius=int(phone_w * 0.12),
        outline=(8, 8, 10, 180),
        width=max(2, int(sw * 0.0028)),
    )

    body_layer = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
    body_layer.paste(body, (phone_left, phone_top), body)
    canvas_rgba = Image.alpha_composite(canvas_rgba, body_layer)

    screen_left = phone_left + shell + bezel
    screen_top = phone_top + shell + bezel
    screen_right = screen_left + sw
    screen_bottom = screen_top + sh
    screen_radius = max(44, int(sw * 0.048))

    # Dark cavity + rounded screenshot glass.
    cavity = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
    cavity_draw = ImageDraw.Draw(cavity)
    cavity_draw.rounded_rectangle(
        [(screen_left - 2, screen_top - 2), (screen_right + 2, screen_bottom + 2)],
        radius=screen_radius + 4,
        fill=(4, 4, 5, 255),
    )
    canvas_rgba = Image.alpha_composite(canvas_rgba, cavity)

    glass_mask = rounded_mask((sw, sh), radius=screen_radius)
    glass_layer = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
    glass_layer.paste(screen, (screen_left, screen_top), glass_mask)
    canvas_rgba = Image.alpha_composite(canvas_rgba, glass_layer)

    # Dynamic island and lens details.
    island_w = int(sw * 0.26)
    island_h = max(52, int(sh * 0.029))
    island_x = screen_left + (sw - island_w) // 2
    island_y = screen_top + max(14, int(bezel * 0.20))
    island = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
    island_draw = ImageDraw.Draw(island)
    island_draw.rounded_rectangle(
        [(island_x, island_y), (island_x + island_w, island_y + island_h)],
        radius=island_h // 2,
        fill=(7, 7, 8, 255),
    )
    cam_r = max(6, int(island_h * 0.14))
    cam_x = island_x + island_w - int(island_h * 0.7)
    cam_y = island_y + island_h // 2
    island_draw.ellipse([(cam_x - cam_r, cam_y - cam_r), (cam_x + cam_r, cam_y + cam_r)], fill=(32, 48, 70, 255))
    island_draw.ellipse([(cam_x - cam_r // 2, cam_y - cam_r // 2), (cam_x + cam_r // 2, cam_y + cam_r // 2)], fill=(12, 16, 20, 255))
    canvas_rgba = Image.alpha_composite(canvas_rgba, island)

    # Side hardware button accents.
    buttons = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
    bdraw = ImageDraw.Draw(buttons)
    side_w = max(4, int(sw * 0.004))
    right_x0 = phone_right - shell - 1
    left_x0 = phone_left + 1
    bdraw.rounded_rectangle(
        [(right_x0, phone_top + int(phone_h * 0.32)), (right_x0 + side_w, phone_top + int(phone_h * 0.52))],
        radius=side_w,
        fill=(126, 130, 139, 220),
    )
    bdraw.rounded_rectangle(
        [(left_x0 - side_w, phone_top + int(phone_h * 0.24)), (left_x0, phone_top + int(phone_h * 0.34))],
        radius=side_w,
        fill=(126, 130, 139, 220),
    )
    bdraw.rounded_rectangle(
        [(left_x0 - side_w, phone_top + int(phone_h * 0.38)), (left_x0, phone_top + int(phone_h * 0.48))],
        radius=side_w,
        fill=(126, 130, 139, 220),
    )
    canvas_rgba = Image.alpha_composite(canvas_rgba, buttons)

    # Glass edge highlight.
    highlight = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
    hdraw = ImageDraw.Draw(highlight)
    hdraw.rounded_rectangle(
        [(screen_left, screen_top), (screen_right, screen_bottom)],
        radius=screen_radius,
        outline=(255, 255, 255, 95),
        width=max(2, int(sw * 0.0026)),
    )
    canvas_rgba = Image.alpha_composite(canvas_rgba, highlight)

    return canvas_rgba.convert("RGB")


def main() -> int:
    args = parse_args()
    source_dir = Path(args.source_dir)
    output_dir = Path(args.output_dir)
    if not source_dir.exists():
        raise FileNotFoundError(f"Source directory does not exist: {source_dir}")

    source_files = sorted(source_dir.glob("*.png"), key=natural_sort_key)
    if not source_files:
        raise FileNotFoundError(f"No PNG screenshots found in: {source_dir}")

    output_dir.mkdir(parents=True, exist_ok=True)

    for source_path in source_files:
        framed = frame_iphone_screenshot(Image.open(source_path))
        output_path = output_dir / source_path.name
        framed.save(output_path, format="PNG")
        print(f"Rendered: {output_path}")

    print(f"Completed {len(source_files)} framed iPhone screenshots.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
