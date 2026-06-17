# Instead — Accessibility Specification

> Accessibility is a design constraint, not a validation step. A component that fails these criteria is not complete.

---

## Standards

| Standard       | Target     | Notes                                              |
|----------------|------------|----------------------------------------------------|
| WCAG 2.2       | AA minimum | AA+ where achievable without harming aesthetics    |
| APCA           | Primary    | Overrides WCAG contrast where WCAG is insufficient |
| ARIA 1.2       | Required   | Correct roles, states, properties                  |
| ATAG 2.0       | Guideline  | For any authoring surfaces                         |

---

## Colour Contrast

### APCA Targets (primary decision model)

| Content type       | APCA Lc target |
|--------------------|----------------|
| Body text          | ≥ 75           |
| Small text (≤14px) | ≥ 80           |
| Large text (≥24px) | ≥ 60           |
| UI controls        | ≥ 60           |
| Placeholder text   | ≥ 60           |
| Icons (functional) | ≥ 60           |
| Focus indicators   | ≥ 75           |

### Dark Theme Targets

| Content type    | APCA Lc target |
|-----------------|----------------|
| Primary text    | ≥ 90           |
| Secondary text  | ≥ 75           |

### WCAG Minimums (floor, not ceiling)

- Body text: 4.5:1
- Large text (≥18pt or ≥14pt bold): 3:1
- Non-text contrast (UI components, graphics): 3:1

### Non-Text Contrast
- Interactive element boundaries (inputs, buttons, checkboxes) must meet 3:1 against adjacent background
- Focus indicator must meet 3:1 against both the component surface and the page background

---

## Focus Management

### Focus Ring
```
outline: 3px solid #2D6CDF;
outline-offset: 2px;
```

Requirements:
- Visible on all backgrounds (blue ring passes against parchment, white, dark surfaces, and Leaf 700)
- Never hidden with `outline: none` without a visible alternative
- Never replaced by subtle box-shadow alone
- Always present on `:focus-visible`, consistently across all interactive elements

### Focus Order
- Logical reading order (left-to-right, top-to-bottom for LTR)
- Modal / sheet open: focus moves to the first focusable element inside
- Modal / sheet close: focus returns to the trigger element
- Dropdowns: focus stays within the open menu until Escape closes it
- No focus trap except in modals, sheets, and drawers

### Skip Links
All page templates must include (in order, before main content):
1. "Skip to main content" → `#main`
2. "Skip to navigation" → `#nav`
3. "Skip to search" → `#search` (where present)

Skip links must be visible on focus (not permanently hidden off-screen).

---

## Keyboard Navigation

### Global Requirements
- Every interactive element reachable and operable by keyboard alone
- No action available only via mouse hover or drag

### Component-Specific Keys

| Component       | Keys                                        |
|-----------------|---------------------------------------------|
| Button          | Enter, Space                                |
| Link            | Enter                                       |
| Checkbox        | Space (toggle)                              |
| Radio group     | Arrow keys (within group), Space (select)   |
| Toggle / Switch | Space, Enter                                |
| Dropdown        | Enter/Space (open), ↑↓ (navigate), Enter (select), Escape (close), Tab (close + move focus) |
| Tabs            | ←→ (switch tabs), Home (first), End (last)  |
| Modal / Sheet   | Escape (close), Tab/Shift+Tab (within trap) |
| Date picker     | ↑↓←→ (days), Enter (select), Escape (close) |

### No Keyboard Trap
Focus must never become permanently trapped. Escape must always provide a clear exit from constrained contexts.

---

## Semantic HTML & ARIA

### Landmarks (required on every page)
```html
<header role="banner">
<nav aria-label="Main navigation">
<main id="main">
<aside aria-label="..."> (where applicable)
<footer role="contentinfo">
```

### Headings
- One `<h1>` per page
- Logical hierarchy: `h1 → h2 → h3` — never skip levels
- Headings describe the section, not the visual style

### ARIA Roles (when semantic HTML is insufficient)

| Pattern            | Role / Attribute                  |
|--------------------|-----------------------------------|
| Tab component      | `role="tablist"` + `role="tab"` + `role="tabpanel"` |
| Modal / dialog     | `role="dialog"` + `aria-modal="true"` + `aria-labelledby` |
| Toggle / switch    | `role="switch"` + `aria-checked`  |
| Dropdown           | `role="listbox"` + `role="option"` + `aria-expanded` |
| Alert / toast      | `role="alert"` or `aria-live="polite"` |
| Navigation item    | `aria-current="page"` on active   |
| Loading / skeleton | `aria-busy="true"` on container   |
| Icon (standalone)  | `aria-label="..."` on button/link, or `role="img" aria-label="..."` on SVG |
| Icon (decorative)  | `aria-hidden="true"`              |
| Illustration       | `aria-hidden="true"` (decorative) |

### Required `aria-label` / `aria-labelledby`
- All form inputs must have an associated `<label>` (visible preferred, `aria-label` acceptable)
- All icon-only buttons must have `aria-label`
- Modals and dialogs must have `aria-labelledby` pointing to their heading
- Navigation landmarks with multiple instances must have distinct `aria-label`

---

## Touch & Pointer Targets

| Requirement                  | Value     |
|------------------------------|-----------|
| Minimum touch target         | 44×44px   |
| Preferred touch target       | 48×48px   |
| Minimum spacing between targets | 8px    |

- Target area may be larger than visual size (use padding, not width/height alone)
- All draggable actions must have a keyboard or pointer alternative
- No actions that require precision dragging as the only interaction method

---

## Zoom & Reflow

### 200% Zoom
- All content and controls remain fully functional
- No horizontal scrolling required
- Text does not overflow its container

### 400% Zoom (WCAG 1.4.10 Reflow)
- Content reflows to single column
- No content loss or truncation
- All controls remain operable
- Horizontal scrolling is never required for text content

---

## Reduced Motion

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: .01ms !important;
    transition-duration: .01ms !important;
    scroll-behavior: auto !important;
  }
}
```

Disable entirely when reduced motion is preferred:
- Parallax effects
- Bounce and spring animations
- Scale / transform decorative effects
- Animated illustrations
- Auto-advancing carousels or slideshows

Essential motion (communicates state change) should reduce to an instant transition, not be removed entirely.

---

## Screen Reader Support

### Tested Combinations (acceptance gate)
| SR         | Browser  | Platform |
|------------|----------|----------|
| VoiceOver  | Safari   | iOS      |
| VoiceOver  | Safari   | macOS    |
| TalkBack   | Chrome   | Android  |
| NVDA       | Firefox  | Windows  |
| NVDA       | Chrome   | Windows  |

### Announcements
- Dynamic content changes must use `aria-live` or `role="status"` / `role="alert"` appropriately
- Form errors must be announced immediately on submission or on blur
- Loading states must announce completion: `aria-busy="false"` + live region update
- Toast / notification messages must be read without requiring focus

---

## Colour Blindness

All state and meaning conveyed by colour must also be conveyed by:
- Shape, icon, or pattern
- Text label
- Position or border

Test with:
- Protanopia (red-blind)
- Deuteranopia (green-blind)
- Tritanopia (blue-blind)
- Achromatopsia (monochromacy)

---

## Windows High Contrast Mode

- Use `forced-colors: active` media query for overrides where needed
- Borders and outlines must be visible — never rely on background-colour alone for boundaries
- Focus rings must survive forced-colour override

---

## Forms & Authentication

- All inputs have visible labels (not placeholder-only)
- Error messages are associated with their field via `aria-describedby`
- Error messages are specific: "Enter a valid email address" not "Invalid input"
- Required fields marked with `aria-required="true"` and a visual indicator
- Authentication must not require cognitive tests that fail WCAG 3.3.8 (Accessible Authentication)
- Paste is never blocked in password fields

---

## Content & Language

- `lang` attribute set on `<html>` element
- Language changes within content marked with `lang` attribute on the element
- Page title (`<title>`) is descriptive and unique per view
- Link text is meaningful out of context — never "click here" or "read more" alone

---

## Acceptance Gate

A component, page, or feature **cannot ship** until it passes all of the following:

- [ ] WCAG 2.2 AA (minimum floor)
- [ ] APCA thresholds for all text and control contrast
- [ ] Keyboard-only navigation (Tab, Shift+Tab, relevant arrow keys, Escape, Enter)
- [ ] VoiceOver on Safari (iOS + macOS)
- [ ] NVDA on Firefox (Windows)
- [ ] TalkBack on Chrome (Android) — for mobile-impacting changes
- [ ] Windows High Contrast Mode
- [ ] 200% zoom — functional, no horizontal scroll
- [ ] 400% zoom — single-column reflow, no content loss
- [ ] Reduced motion — no jarring animation at `prefers-reduced-motion: reduce`
- [ ] Colour blindness simulation — no state conveyed by colour alone
- [ ] Touch targets ≥ 44×44px on all interactive elements
