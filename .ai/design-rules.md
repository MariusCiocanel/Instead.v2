# Instead — Design Rules for AI Agents

All UI code generated for Instead must follow these rules without exception.

---

## Colours

- Use semantic CSS custom properties only (`--primary`, `--text-primary`, `--bg`, `--surface`, etc.)
- Never reference raw hex values inside components — always go through the token layer in `src/styles/tokens.css`
- Never use these prohibited combinations: Leaf 500 on Pear 100, Moss 300 on white, Ink 500 on Moss 300

## Typography

- Headings: `--font-heading` (Fraunces)
- Body: `--font-body` (Inter)
- Logo only: `--font-logo` (Caveat)
- Never set font-family to a raw font name — always use the CSS variable

## Accessibility — Non-Negotiable

- Minimum touch target: **44×44px** for all interactive elements
- Every interactive element must be keyboard-reachable and have a visible focus ring (`outline: 3px solid var(--focus-ring); outline-offset: 2px`)
- Icons used alone must have `aria-label` or a visually-hidden label
- Decorative illustrations must have `aria-hidden="true"`
- Modals must trap focus, restore focus on close, and close on Escape
- Never use colour as the only means of conveying state
- Labels must always be visible — never placeholder-only inputs
- Toggles and checkboxes must announce state to screen readers

## Never Do

- Red notification badges or dot-counters designed to create urgency
- Infinite scrolling
- Engagement metrics or streak counters
- Dark patterns (false urgency, confirmshaming, hidden unsubscribe)
- Non-token colours in component code
- `opacity` reduction below readable levels for disabled states (use `--disabled: #CFCFCF` instead)
- Auto-dismiss toasts for critical information

## Motion

- Hover: `var(--motion-fast)` (100ms)
- Press: `var(--motion-press)` (75ms)
- Open/enter: `var(--motion-medium)` (150ms)
- Page transition: `var(--motion-slow)` (200ms)
- Always wrap animations in `@media (prefers-reduced-motion: no-preference)` — the default state should have no animation

## Voice & Tone

- Calm, kind, encouraging
- Help the user slow down, not add more
- Avoid words that create urgency: "now", "quick", "don't miss", "limited"
- Empty states: use the partridge illustration + short, warm guidance + one clear action

## Component Acceptance Gate

A component is not complete until it passes:
- WCAG 2.2 AA minimum
- APCA Lc ≥75 for body text, Lc ≥80 for small text
- Keyboard-only navigation
- Screen reader tested
- 400% zoom — no content loss, no horizontal scroll
- Reduced motion respected

## Token Files

- `design/tokens.json` — primitive values
- `design/themes.json` — light and dark semantic mappings
- `design/components.json` — component contracts
- `src/styles/tokens.css` — CSS custom properties (source of truth for the app)
- `docs/design-system.md` — full human-readable spec
