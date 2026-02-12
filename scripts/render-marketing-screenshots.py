#!/usr/bin/env python3

from __future__ import annotations

import argparse
import textwrap
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

SHOT_DECK = [
    {
        "source": "screenshot-1-todos-list",
        "slug": "daily-focus",
        "headline": "Your chaos, sorted.",
        "subtitle": "Droll tasks, crisp priorities, zero drama.",
        "palette": ((27, 61, 95), (57, 140, 192)),
    },
    {
        "source": "screenshot-2-sign-in",
        "slug": "sync-anywhere",
        "headline": "Sign in. Sync everywhere.",
        "subtitle": "Same quirky tasks on every screen you own.",
        "palette": ((23, 89, 76), (67, 170, 139)),
    },
    {
        "source": "screenshot-3-task-edit",
        "slug": "task-detail-control",
        "headline": "Details without the detour.",
        "subtitle": "Dates, notes, priority, and category in one stop.",
        "palette": ((110, 47, 83), (194, 91, 128)),
    },
    {
        "source": "screenshot-4-category-view",
        "slug": "category-clarity",
        "headline": "Group by what matters.",
        "subtitle": "House. Finance. Tech. The usual suspects.",
        "palette": ((106, 71, 32), (225, 140, 53)),
    },
    {
        "source": "screenshot-5-appearance",
        "slug": "theme-personality",
        "headline": "Style that fits your mood.",
        "subtitle": "Pick a palette, keep your personality.",
        "palette": ((37, 73, 122), (117, 169, 236)),
    },
    {
        "source": "screenshot-6-priority-view",
        "slug": "priority-at-a-glance",
        "headline": "See urgency instantly.",
        "subtitle": "High first, deferred later, guilt optional.",
        "palette": ((95, 45, 27), (196, 113, 78)),
    },
]

FONT_BOLD_CANDIDATES = [
    "/System/Library/Fonts/SFNSRounded.ttf",
    "/System/Library/Fonts/SFNS.ttf",
    "/System/Library/Fonts/Helvetica.ttc",
]

FONT_REGULAR_CANDIDATES = [
    "/System/Library/Fonts/SFNS.ttf",
    "/System/Library/Fonts/Helvetica.ttc",
    "/System/Library/Fonts/Avenir.ttc",
]

DEVICE_LABELS = {
    "iphone": "iPhone",
    "ipad": "iPad",
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Render marketing composites from raw screenshots.")
    parser.add_argument("--source-root", required=True, help="Root folder containing device raw folders.")
    parser.add_argument("--output-root", required=True, help="Root folder for rendered marketing assets.")
    return parser.parse_args()


def load_font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates = FONT_BOLD_CANDIDATES if bold else FONT_REGULAR_CANDIDATES
    for path in candidates:
        font_path = Path(path)
        if font_path.exists():
            try:
                return ImageFont.truetype(str(font_path), size=size)
            except OSError:
                continue
    return ImageFont.load_default()


def interpolate_color(top: tuple[int, int, int], bottom: tuple[int, int, int], t: float) -> tuple[int, int, int]:
    return tuple(int(top[i] + (bottom[i] - top[i]) * t) for i in range(3))


def draw_vertical_gradient(canvas: Image.Image, top: tuple[int, int, int], bottom: tuple[int, int, int]) -> None:
    draw = ImageDraw.Draw(canvas)
    width, height = canvas.size
    for y in range(height):
        t = y / max(1, height - 1)
        draw.line([(0, y), (width, y)], fill=interpolate_color(top, bottom, t))


def rounded_mask(size: tuple[int, int], radius: int) -> Image.Image:
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([(0, 0), (size[0], size[1])], radius=radius, fill=255)
    return mask


def wrap_text(draw: ImageDraw.ImageDraw, text: str, font: ImageFont.ImageFont, max_width: int, max_lines: int = 3) -> str:
    words = text.split()
    lines: list[str] = []
    current = ""

    for word in words:
        candidate = word if not current else f"{current} {word}"
        if draw.textlength(candidate, font=font) <= max_width:
            current = candidate
        else:
            if current:
                lines.append(current)
            current = word
            if len(lines) == max_lines - 1:
                break

    if current and len(lines) < max_lines:
        lines.append(current)

    if not lines:
        return textwrap.shorten(text, width=30, placeholder="...")

    if len(lines) == max_lines and " ".join(words).strip() != " ".join(lines).strip():
        lines[-1] = textwrap.shorten(lines[-1], width=max(8, len(lines[-1]) - 4), placeholder="...")

    return "\n".join(lines)


def render_marketing_asset(
    source_path: Path,
    output_path: Path,
    headline: str,
    subtitle: str,
    palette: tuple[tuple[int, int, int], tuple[int, int, int]],
    device_label: str,
) -> None:
    source = Image.open(source_path).convert("RGBA")
    width, height = source.size

    canvas = Image.new("RGB", (width, height), color=palette[0])
    draw_vertical_gradient(canvas, palette[0], palette[1])
    draw = ImageDraw.Draw(canvas)

    badge_font = load_font(max(26, int(width * 0.027)), bold=True)
    headline_font = load_font(max(44, int(width * 0.062)), bold=True)
    subtitle_font = load_font(max(26, int(width * 0.03)), bold=False)
    device_font = load_font(max(24, int(width * 0.025)), bold=True)

    side_padding = int(width * 0.055)
    top_padding = int(height * 0.045)
    text_gap = int(height * 0.018)

    badge_text = "NOTELAYER"
    badge_box_h = int(height * 0.05)
    badge_box_w = int(draw.textlength(badge_text, font=badge_font) + width * 0.07)
    badge_rect = [
        side_padding,
        top_padding,
        side_padding + badge_box_w,
        top_padding + badge_box_h,
    ]
    draw.rounded_rectangle(badge_rect, radius=int(badge_box_h * 0.5), fill=(255, 255, 255, 230))
    draw.text((badge_rect[0] + width * 0.028, badge_rect[1] + badge_box_h * 0.17), badge_text, fill=(20, 25, 37), font=badge_font)

    device_text = device_label.upper()
    device_w = int(draw.textlength(device_text, font=device_font))
    draw.text((width - side_padding - device_w, top_padding + badge_box_h * 0.15), device_text, fill=(244, 248, 255), font=device_font)

    headline_y = badge_rect[3] + text_gap
    wrapped_headline = wrap_text(draw, headline, headline_font, width - side_padding * 2, max_lines=2)
    draw.multiline_text(
        (side_padding, headline_y),
        wrapped_headline,
        font=headline_font,
        fill=(255, 255, 255),
        spacing=int(height * 0.006),
    )

    headline_box = draw.multiline_textbbox((side_padding, headline_y), wrapped_headline, font=headline_font, spacing=int(height * 0.006))
    subtitle_y = headline_box[3] + int(height * 0.012)
    wrapped_subtitle = wrap_text(draw, subtitle, subtitle_font, width - side_padding * 2, max_lines=2)
    draw.multiline_text(
        (side_padding, subtitle_y),
        wrapped_subtitle,
        font=subtitle_font,
        fill=(236, 243, 255),
        spacing=int(height * 0.004),
    )

    subtitle_box = draw.multiline_textbbox((side_padding, subtitle_y), wrapped_subtitle, font=subtitle_font, spacing=int(height * 0.004))

    frame_top = subtitle_box[3] + int(height * 0.03)
    frame_left = side_padding
    frame_right = width - side_padding
    frame_bottom = height - int(height * 0.038)
    frame_radius = int(width * 0.05)

    shadow = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_offset = max(8, int(height * 0.006))
    shadow_draw.rounded_rectangle(
        [(frame_left + shadow_offset, frame_top + shadow_offset), (frame_right + shadow_offset, frame_bottom + shadow_offset)],
        radius=frame_radius,
        fill=(0, 0, 0, 85),
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=max(6, int(width * 0.008))))
    canvas = Image.alpha_composite(canvas.convert("RGBA"), shadow)

    panel = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    panel_draw = ImageDraw.Draw(panel)
    panel_draw.rounded_rectangle(
        [(frame_left, frame_top), (frame_right, frame_bottom)],
        radius=frame_radius,
        fill=(245, 248, 255, 252),
        outline=(255, 255, 255, 220),
        width=max(2, int(width * 0.003)),
    )
    canvas = Image.alpha_composite(canvas, panel)

    inset = int(width * 0.028)
    content_left = frame_left + inset
    content_top = frame_top + inset
    content_right = frame_right - inset
    content_bottom = frame_bottom - inset
    content_w = content_right - content_left
    content_h = content_bottom - content_top

    scale = min(content_w / source.width, content_h / source.height)
    resized = source.resize((int(source.width * scale), int(source.height * scale)), Image.Resampling.LANCZOS)

    app_x = content_left + (content_w - resized.width) // 2
    app_y = content_top + (content_h - resized.height) // 2

    screenshot_radius = int(width * 0.04)
    mask = rounded_mask(resized.size, radius=screenshot_radius)

    screenshot_layer = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    screenshot_layer.paste(resized, (app_x, app_y), mask=mask)
    canvas = Image.alpha_composite(canvas, screenshot_layer)

    border_layer = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    border_draw = ImageDraw.Draw(border_layer)
    border_draw.rounded_rectangle(
        [(app_x, app_y), (app_x + resized.width, app_y + resized.height)],
        radius=screenshot_radius,
        outline=(210, 220, 238, 230),
        width=max(2, int(width * 0.0025)),
    )
    canvas = Image.alpha_composite(canvas, border_layer)

    output_path.parent.mkdir(parents=True, exist_ok=True)
    canvas.convert("RGB").save(output_path, format="PNG")


def main() -> int:
    args = parse_args()
    source_root = Path(args.source_root)
    output_root = Path(args.output_root)

    if not source_root.exists():
        raise FileNotFoundError(f"Source root does not exist: {source_root}")

    missing_inputs: list[Path] = []

    for device_key, device_label in DEVICE_LABELS.items():
        device_input_dir = source_root / device_key
        if not device_input_dir.exists():
            continue

        for index, shot in enumerate(SHOT_DECK, start=1):
            source_name = f"{device_key}-{shot['source']}.png"
            source_path = device_input_dir / source_name
            if not source_path.exists():
                missing_inputs.append(source_path)
                continue

            output_name = f"{index:02d}-{shot['slug']}.png"
            output_path = output_root / device_key / output_name
            render_marketing_asset(
                source_path=source_path,
                output_path=output_path,
                headline=shot["headline"],
                subtitle=shot["subtitle"],
                palette=shot["palette"],
                device_label=device_label,
            )
            print(f"Rendered: {output_path}")

    if missing_inputs:
        print("Missing source screenshots:")
        for path in missing_inputs:
            print(f"  - {path}")
        return 1

    print("Marketing composites complete.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
