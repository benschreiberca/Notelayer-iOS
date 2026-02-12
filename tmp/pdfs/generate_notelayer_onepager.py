from __future__ import annotations

from datetime import date
from pathlib import Path

from reportlab.lib.colors import HexColor
from reportlab.lib.pagesizes import letter
from reportlab.lib.utils import simpleSplit
from reportlab.pdfgen import canvas

OUTPUT_PATH = Path("output/pdf/notelayer_app_summary_one_pager.pdf")

TITLE = "Notelayer iOS - One-Page Summary"
SUBTITLE = f"Repo evidence only | Generated {date.today().isoformat()}"

SECTIONS = [
    (
        "What it is",
        [
            "Notelayer is a native SwiftUI iOS app for managing notes and to-dos with categories, reminders, calendar export, and cloud sync.",
            "The root experience is a three-tab layout: Notes, To-Dos, and Insights.",
        ],
    ),
    (
        "Who it's for",
        [
            "Primary persona: Not found in repo.",
            "Inferred from repo docs: iOS users who want a personal operations dashboard for planning, completing, and reviewing tasks over time.",
        ],
    ),
    (
        "What it does",
        [
            "Captures and manages notes and tasks with title, categories, priority, due date, and task notes.",
            "Supports four task organization modes: List, Priority, Category, and Date.",
            "Schedules local reminders and supports notification actions to complete or open tasks.",
            "Exports tasks into Apple Calendar using EventKit event editing.",
            "Syncs notes, tasks, and categories to Firebase Firestore for authenticated users.",
            "Provides an Insights tab with trends, category stats, feature usage, time-of-day usage, and gap drilldowns.",
            "Processes iOS Share Extension items into tasks via App Group storage.",
        ],
    ),
    (
        "How it works",
        [
            "UI components: NotelayerApp initializes AuthService and FirebaseBackendService, then presents RootTabsView with NotesView, TodosView, and InsightsView.",
            "Data layer: LocalStore is the app's observable local source of truth and persists notes/tasks/categories to App Group UserDefaults.",
            "Sync layer: FirebaseBackendService reacts to auth state, binds LocalStore to Firestore user collections, runs initial sync, and keeps live listeners active.",
            "Feature services: ReminderManager handles UserNotifications, CalendarExportManager handles EventKit export, and ThemeManager controls appearance tokens.",
            "Telemetry flow: AnalyticsService logs to Firebase Analytics and mirrors events into InsightsTelemetryStore; InsightsAggregator builds snapshots for InsightsView.",
            "Data flow: UI action -> LocalStore mutation -> local persist plus optional backend upsert and side effects; remote updates -> backend listeners -> LocalStore applyRemote methods -> SwiftUI refresh.",
        ],
    ),
    (
        "How to run",
        [
            "Install Xcode on macOS.",
            "Open ios-swift/Notelayer/Notelayer.xcodeproj in Xcode.",
            "Select an iPhone simulator (or connected device).",
            "Press Cmd+R to build and run.",
            "For physical device runs, Apple Developer account details may be required for signing.",
        ],
    ),
]

SOURCES = [
    "docs/Project_Readme.md",
    "docs/Quick_Start.md",
    "docs/Project_Changelog.md",
    "docs/App_Store_Release_Notes.md",
    "ios-swift/Notelayer/Notelayer/App/NotelayerApp.swift",
    "ios-swift/Notelayer/Notelayer/Views/RootTabsView.swift",
    "ios-swift/Notelayer/Notelayer/Views/TodosView.swift",
    "ios-swift/Notelayer/Notelayer/Views/InsightsView.swift",
    "ios-swift/Notelayer/Notelayer/Data/LocalStore.swift",
    "ios-swift/Notelayer/Notelayer/Services/FirebaseBackendService.swift",
    "ios-swift/Notelayer/Notelayer/Services/ReminderManager.swift",
    "ios-swift/Notelayer/Notelayer/Services/CalendarExportManager.swift",
    "ios-swift/Notelayer/Notelayer/Services/AnalyticsService.swift",
    "ios-swift/Notelayer/Notelayer/Data/SharedItem.swift",
]

PAGE_WIDTH, PAGE_HEIGHT = letter
MARGIN_X = 40
TOP_MARGIN = 36
BOTTOM_MARGIN = 28
TEXT_WIDTH = PAGE_WIDTH - (MARGIN_X * 2)


def wrapped_lines(text: str, font_name: str, font_size: float, width: float) -> list[str]:
    return simpleSplit(text, font_name, font_size, width)


def measure_height(body_size: float, heading_size: float, source_size: float) -> float:
    title_size = heading_size + 5.0
    subtitle_size = body_size - 0.6

    body_leading = body_size + 3.1
    heading_leading = heading_size + 2.0
    source_leading = source_size + 2.0

    total = 0.0
    total += title_size + 6.0
    total += subtitle_size + 14.0

    for heading, items in SECTIONS:
        total += heading_leading + 2.0
        for item in items:
            lines = wrapped_lines(f"- {item}", "Helvetica", body_size, TEXT_WIDTH)
            total += (len(lines) * body_leading) + 1.8
        total += 3.6

    source_text = "Sources: " + ", ".join(SOURCES)
    source_lines = wrapped_lines(source_text, "Helvetica", source_size, TEXT_WIDTH)
    total += source_leading + 1.0
    total += len(source_lines) * source_leading

    return total


def choose_sizes() -> tuple[float, float, float]:
    options = [
        (9.6, 11.0, 6.8),
        (9.3, 10.8, 6.6),
        (9.0, 10.6, 6.4),
        (8.7, 10.4, 6.2),
        (8.4, 10.2, 6.0),
    ]
    usable_height = PAGE_HEIGHT - TOP_MARGIN - BOTTOM_MARGIN
    for body_size, heading_size, source_size in options:
        if measure_height(body_size, heading_size, source_size) <= usable_height:
            return body_size, heading_size, source_size
    return options[-1]


def draw_pdf(path: Path) -> None:
    body_size, heading_size, source_size = choose_sizes()

    title_size = heading_size + 5.0
    subtitle_size = body_size - 0.6

    body_leading = body_size + 3.1
    heading_leading = heading_size + 2.0
    source_leading = source_size + 2.0

    c = canvas.Canvas(str(path), pagesize=letter)
    y = PAGE_HEIGHT - TOP_MARGIN

    c.setFillColor(HexColor("#111827"))
    c.setFont("Helvetica-Bold", title_size)
    c.drawString(MARGIN_X, y, TITLE)
    y -= title_size + 6

    c.setFillColor(HexColor("#4B5563"))
    c.setFont("Helvetica", subtitle_size)
    c.drawString(MARGIN_X, y, SUBTITLE)
    y -= subtitle_size + 12

    c.setStrokeColor(HexColor("#D1D5DB"))
    c.setLineWidth(0.8)
    c.line(MARGIN_X, y, PAGE_WIDTH - MARGIN_X, y)
    y -= 10

    for heading, items in SECTIONS:
        c.setFillColor(HexColor("#1F2937"))
        c.setFont("Helvetica-Bold", heading_size)
        c.drawString(MARGIN_X, y, heading)
        y -= heading_leading

        c.setFillColor(HexColor("#111827"))
        c.setFont("Helvetica", body_size)
        for item in items:
            lines = wrapped_lines(f"- {item}", "Helvetica", body_size, TEXT_WIDTH)
            for line in lines:
                c.drawString(MARGIN_X, y, line)
                y -= body_leading
            y -= 1.8

        y -= 1.8

    c.setFillColor(HexColor("#4B5563"))
    c.setFont("Helvetica-Bold", source_size)
    c.drawString(MARGIN_X, y, "Evidence files")
    y -= source_leading

    c.setFont("Helvetica", source_size)
    source_text = "Sources: " + ", ".join(SOURCES)
    for line in wrapped_lines(source_text, "Helvetica", source_size, TEXT_WIDTH):
        c.drawString(MARGIN_X, y, line)
        y -= source_leading

    c.save()


def main() -> None:
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    draw_pdf(OUTPUT_PATH)
    print(str(OUTPUT_PATH.resolve()))


if __name__ == "__main__":
    main()
