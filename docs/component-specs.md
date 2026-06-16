# Instead — Component Specifications

> Concrete contracts for every component. Token references use keys from `design/themes.json`.
> Accessibility requirements from `docs/accessibility.md` apply to all components.

---

## Buttons

### Primary Button

| Property       | Value                                    |
|----------------|------------------------------------------|
| Height         | 48px preferred / 44px minimum            |
| Min touch area | 44×44px                                  |
| Padding        | 12px 24px                                |
| Background     | `actionPrimary`                          |
| Text colour    | `textInverse`                            |
| Font           | `--font-body`, 500, 16px                 |
| Radius         | `--radius-md` (12px)                     |

**States**

| State    | Change from default                         |
|----------|---------------------------------------------|
| Hover    | Background → `actionPrimaryHover` (150ms)   |
| Active   | Background → `actionPrimaryActive` (75ms)   |
| Focus    | 3px ring `focus`, offset 2px                |
| Disabled | Background → `disabled`, cursor not-allowed, no opacity below legible |

---

### Secondary Button

| Property    | Value                              |
|-------------|------------------------------------|
| Background  | transparent                        |
| Border      | 2px solid `actionPrimary`          |
| Text colour | `actionPrimary`                    |
| All other specs match Primary |            |

**States**

| State  | Change                                      |
|--------|---------------------------------------------|
| Hover  | Background → `surface` (150ms)              |
| Active | Background → `border` tint (75ms)           |

---

### Destructive Button

| Property    | Value            |
|-------------|------------------|
| Background  | `error`          |
| Text colour | `textInverse`    |
| All other specs match Primary |  |

---

## Inputs

### Text Input

| Property       | Value                                |
|----------------|--------------------------------------|
| Height         | 48px                                 |
| Padding        | 12px 16px                            |
| Border         | 2px solid `border`                   |
| Border (focus) | 2px solid `focus`                    |
| Background     | `surface`                            |
| Text colour    | `textPrimary`                        |
| Label          | `textPrimary`, 14px, always visible  |
| Radius         | `--radius-md` (12px)                 |

**States**

| State   | Change                                 |
|---------|----------------------------------------|
| Default | Border `border`                        |
| Focus   | Border `focus` + focus ring            |
| Error   | Border `error`, error text `error`     |
| Filled  | No change from default                 |
| Disabled| Background `disabled`, text `textMuted`|

**Rules**
- Label is always visible above or beside the field
- Placeholder may exist as supplementary hint only — never as the sole label
- Error message appears below the field, associated via `aria-describedby`

---

### Search Input

Same specs as Text Input, plus:

| Property       | Value                                         |
|----------------|-----------------------------------------------|
| Leading icon   | Search (outline, 20px, `textMuted`, `aria-hidden`) |
| Clear button   | Appears when value is non-empty, `aria-label="Clear search"` |
| Min width      | 240px                                         |

---

## Tabs

| Property          | Value                                          |
|-------------------|------------------------------------------------|
| Tab height        | 44px minimum                                   |
| Active indicator  | 2px underline `actionPrimary`                  |
| Active text       | `actionPrimary`, 500 weight                    |
| Default text      | `textSecondary`, 400 weight                    |
| Hover text        | `textPrimary`                                  |
| Keyboard          | ←→ switch, Home first, End last                |
| ARIA              | `tablist` / `tab` / `tabpanel` + `aria-selected` |

---

## Cards

### Default Card

| Property   | Value                          |
|------------|--------------------------------|
| Background | `surface`                      |
| Border     | 1px solid `border`             |
| Padding    | 24px minimum                   |
| Radius     | `--radius-lg` (16px)           |
| Shadow     | `--shadow-1`                   |

**Interactive Card (clickable / hoverable)**

| State | Change                                |
|-------|---------------------------------------|
| Hover | Background → `surfaceRaised`, `--shadow-2` (150ms) |
| Focus | Focus ring on the card or its primary action |
| Active| `--shadow-1` (75ms)                   |

**Rules**
- No information or action available only on hover
- If the entire card is a link, use a single `<a>` wrapping the card with a meaningful `aria-label`

---

## Sheets & Modals

### Bottom Sheet (mobile primary)

| Property       | Value                                   |
|----------------|-----------------------------------------|
| Background     | `surfaceRaised`                         |
| Border top     | 1px solid `border`                      |
| Radius         | `--radius-xl` (24px) top corners only   |
| Drag handle    | 4px × 32px, `border`, centered at top   |
| Padding        | 24px                                    |
| Backdrop       | rgba(0,0,0,0.4), `aria-hidden="true"`   |

**Behaviour**
- Opens: slides up from bottom, 200ms ease-out
- Closes: Escape, backdrop tap, explicit close button
- Focus: moves to first focusable element on open; returns to trigger on close
- `role="dialog"`, `aria-modal="true"`, `aria-labelledby` pointing to heading

---

### Modal (desktop primary)

| Property   | Value                                         |
|------------|-----------------------------------------------|
| Background | `surfaceRaised`                               |
| Radius     | `--radius-lg` (16px)                          |
| Padding    | 32px                                          |
| Max width  | 480px default / 640px wide variant            |
| Shadow     | `--shadow-3`                                  |
| Backdrop   | rgba(0,0,0,0.4), `aria-hidden="true"`         |

**Same behaviour rules as Bottom Sheet.**

---

## Toasts & Notifications

| Property      | Value                                              |
|---------------|----------------------------------------------------|
| Min width     | 280px                                              |
| Max width     | 480px                                              |
| Padding       | 12px 16px                                          |
| Radius        | `--radius-md` (12px)                               |
| Background    | variant-specific (`success`, `error`, `warning`, `info`) |
| Text          | `textInverse`                                      |
| Position      | Bottom-right desktop / bottom-centre mobile        |

**Variants**

| Variant | Background token | Icon     |
|---------|-----------------|----------|
| Success | `success`       | Check    |
| Error   | `error`         | X circle |
| Warning | `warning`       | Warning  |
| Info    | `info`          | Info     |

**Rules**
- `role="alert"` for errors/warnings; `aria-live="polite"` for success/info
- Never auto-dismiss errors or destructive confirmations
- Success toasts may auto-dismiss after 5s minimum
- Always include a manual dismiss button with `aria-label="Dismiss"`

---

## Lists (Bookmark List)

### Bookmark Item

| Property       | Value                                          |
|----------------|------------------------------------------------|
| Min height     | 64px                                           |
| Padding        | 16px                                           |
| Background     | `surfaceRaised`                                |
| Border bottom  | 1px solid `border`                             |
| Title          | `textPrimary`, 500, 16px                       |
| URL / subtitle | `textMuted`, 400, 14px                         |
| Tag badge      | `surface`, `border`, `textSecondary`, 12px     |

**States**

| State  | Change                                |
|--------|---------------------------------------|
| Hover  | Background slight tint (`surface`)    |
| Focus  | Focus ring on primary action or row   |
| Active | Quick archive / swipe gesture + keyboard equivalent |

**Rules**
- Swipe-to-archive must have a keyboard-accessible alternative
- Three-dot overflow menu must be reachable by keyboard
- No action available only on hover

---

## Navigation

### Sidebar Navigation Item

| Property   | Value                                        |
|------------|----------------------------------------------|
| Height     | 44px minimum                                 |
| Padding    | 8px 12px                                     |
| Text       | `textSecondary`, 400, 16px (default)         |
| Icon       | 20px, `textMuted` (default)                  |

**States**

| State  | Change                                            |
|--------|---------------------------------------------------|
| Hover  | Background → `surface`, text → `textPrimary`      |
| Active | Background → `actionPrimary`, text → `textInverse`, icon → `textInverse` |
| Focus  | Focus ring                                        |

**Rules**
- Active item: `aria-current="page"`
- Nav landmark: `<nav aria-label="Main navigation">`
- When collapsed on mobile, navigation must still be reachable by keyboard

---

## Toggles

| Property   | Value                                   |
|------------|-----------------------------------------|
| Track width | 52px minimum                           |
| Track height | 28px                                  |
| Thumb size  | 22×22px                                |
| On track   | `actionPrimary`                         |
| Off track  | `border`                                |
| Thumb      | `textInverse`                           |

**Rules**
- `role="switch"`, `aria-checked="true/false"`
- State change announced by screen reader without requiring re-focus
- Transition: 150ms (off when `prefers-reduced-motion`)

---

## Empty States

### Structure (required)

```
[Partridge illustration — aria-hidden="true"]
[Heading — h2 or h3, textPrimary]
[Body — warm, 1-2 sentences, textSecondary]
[Action button — primary or secondary]
```

**Examples**

| Context             | Heading           | Body                                                 | Action         |
|---------------------|-------------------|------------------------------------------------------|----------------|
| No bookmarks        | Nothing saved yet | The things worth returning to will live here.        | Save something |
| Empty collection    | Collection is empty | Add bookmarks to gather what belongs together.      | Browse all     |
| No search results   | No matches        | Try a different word, or browse by tag.              | Clear search   |
| Empty archive       | Archive is clear  | Archived bookmarks appear here when you're ready to review them. | — |

---

## Loading States

### Skeleton (preferred)

- Represents the shape of the incoming content
- Background: `surface` with shimmer overlay using `border` tint
- Radius matches the actual content
- `aria-busy="true"` on the containing region
- Announce completion: `aria-busy="false"` + live region "Loaded"

### Spinner (fallback only)

- Use only when skeleton shape is unknown or impractical
- Maximum recommended use before switching to a message: 3 seconds
- `role="status"`, `aria-label="Loading..."`
- Size: 24px default, 40px for full-page

---

## Icons

| Property     | Value                                      |
|--------------|--------------------------------------------|
| Style        | Outline, rounded ends                      |
| Stroke width | 1.75px                                     |
| Base grid    | 24×24px                                    |
| In-text      | 1em × 1em, aligned to baseline            |
| Touch target | 44×44px minimum for interactive icons     |

**Usage rules**
- Standalone interactive icon must have `aria-label` on its parent button/link
- Decorative icon must have `aria-hidden="true"`
- Never convey state by icon colour alone — pair with label or shape change
- Icon set: Bookmark, Collection, Tag, Archive, Queue, Search (outline variants only)
