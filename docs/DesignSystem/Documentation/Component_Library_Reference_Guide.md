# Component Library

This is the design-system mapping for core components.

## Button
- Primary background: ComponentTokens.ButtonTokens.primaryBackground
- Primary text: ComponentTokens.ButtonTokens.primaryText

## Card (InsetCard)
- Background: ComponentTokens.CardTokens.background
- Border: ComponentTokens.CardTokens.border
- Corner radius: ComponentTokens.CardTokens.cornerRadius

## Task Item
- Background: ComponentTokens.TaskItemTokens.background
- Title text: ComponentTokens.TaskItemTokens.titleText
- Meta text: ComponentTokens.TaskItemTokens.metaText

## Badge / Chip
- Selected: fill = BadgeTokens.selectedBackground
- Unselected: outline = BadgeTokens.unselectedBorder

## Group Header (Todos)
- Title text: GroupHeaderTokens.titleText
- Count pill: GroupHeaderTokens.countBackground + countText

## Data Row Patterns (Drilldowns)
- Standard contract: primary (left), optional secondary (below), trailing value (right).
- Use one shared row pattern for all drilldown tables to avoid section-specific styling drift.
- Reference: `docs/DesignSystem/Documentation/Data_Row_Patterns_Reference_Guide.md`
