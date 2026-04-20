# PRD 14: AI-Powered Analytics Intelligence

Last Updated: 2026-04-20
Status: Draft
Feature Area: AI / Analytics
Priority: High

## Purpose

Move the Insights / Analytics tab from static charts to an intelligent layer that generates real, personalized observations and recommendations — making the data actually useful.

## Problem Statement

The current Analytics/Insights screen shows charts and aggregate numbers, but the user must interpret everything themselves. Most users look at the charts, feel nothing specific, and leave. The data is there; the intelligence is not.

## Goals

- Generate natural-language summaries that tell users something they did not already know.
- Highlight patterns, anomalies, and trends automatically.
- Give actionable recommendations, not just observations.
- This is a Pro-tier feature (see PRD 13 Freemium Model).

## Non-Goals

- Real-time streaming AI (batch or on-demand is fine for v1).
- General AI assistant / chatbot for tasks.
- Running a large model on-device (use Claude API or equivalent).

## In Scope

### Intelligent Summaries

- Weekly summary card: "Last week you completed X tasks. Your busiest day was Wednesday. Work tasks had a 72% completion rate — your best category."
- Monthly trend narrative: identify if productivity is increasing, declining, or flat.
- Anomaly detection: "You have 14 overdue Personal tasks — that is 3x your usual backlog."

### Smart Recommendations

- "You tend to complete tasks added on Monday by Friday. Tasks added on Thursday often stay open for 2+ weeks — consider a shorter deadline."
- Category health signals: flag categories with very low completion rates.

### AI Integration

- Send anonymized, aggregated task statistics to Claude API (not task content — privacy-first).
- Data sent: category names, task counts, completion rates, date ranges, streaks. No task titles or note content.
- Generate a structured JSON response from Claude; render it in the app as a card-based feed.
- Cache AI responses locally for 24 hours (avoid excessive API calls and cost).

### Privacy

- AI summary generation is opt-in on first use.
- Clear disclosure: what data is sent and that it is anonymized.
- No task content (titles, notes, tags) ever leaves the device.

## Technical Notes

- Use Claude API (Haiku or Sonnet tier for cost efficiency).
- Build a `AnalyticsInsightService` that formats the stats payload, calls the API, parses the response, and caches results.
- Prompt engineering: system prompt specifies tone (encouraging, direct, brief), format (JSON with `summary`, `highlights[]`, `recommendations[]`), and constraints (no made-up data, flag when data is insufficient).

## Acceptance Criteria

- [ ] Weekly summary card appears in Insights tab for Pro users.
- [ ] AI content refreshes on demand and automatically every 24 hours.
- [ ] No task titles or content are included in any API payload (verified by network inspection in tests).
- [ ] Free users see a teaser of the AI card with a Pro upgrade prompt.
- [ ] Opt-in disclosure screen shown before first AI summary generation.
- [ ] AI content degrades gracefully (shows last cached result or a message) when offline.
- [ ] Latency under 3 seconds for summary generation on a good network connection.

## Related

- PRD 02: Analytics Natural Language Insights (earlier exploration — review for overlap).
- PRD 03: Analytics Insights Toggle.
- PRD 13: Freemium Model (this is the flagship Pro feature).
- `Insights_Implementation_Plan.md`
- `PRD_02_Analytics_Natural_Language_Insights.md`
