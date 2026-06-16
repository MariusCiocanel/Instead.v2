# Instead Design System v1.0

> A mindful bookmark manager. Accessibility-first · WCAG 2.2 AA+ · APCA-driven · Production-ready.

---

## 1. Brand Foundation

### Mission
Help people remember what matters without overwhelming them.

### Core Principles
1. **Intentional over Efficient** — avoid unnecessary speed and urgency
2. **Quiet over Loud** — the interface never competes for attention
3. **Meaning over Quantity** — emphasize value, not counts
4. **Human over System** — language feels warm and supportive
5. **Accessible by Default** — everyone can use Instead regardless of ability

### Personality

| Trait       | Expression           |
|-------------|----------------------|
| Calm        | Low visual noise     |
| Thoughtful  | Deliberate spacing   |
| Human       | Warm language        |
| Trustworthy | Strong accessibility |
| Patient     | No urgency patterns  |
| Premium     | Quality typography   |

### Emotional Goals
Users should feel: **safe, focused, organized, unrushed, in control.**
Never: pressured, addicted, overstimulated.

### Brand Mark
- **Mascot:** The Partridge — guardian, curator, guide
- **Symbol:** The Pear Tree — growth, memory, nourishment
- Mascot appears in empty states, onboarding, illustrations, loading moments
- Must not replace navigation, labels, or accessibility text

---

## 2. Colour System

### Accessibility Strategy
APCA is the primary decision-making model. WCAG is the minimum floor.

| Usage      | APCA target |
|------------|-------------|
| Body text  | Lc 75+      |
| Small text | Lc 80+      |
| Large text | Lc 60+      |
| Controls   | Lc 60+      |

### Light Theme Palette

| Token       | Hex       | Usage                         | Notes                         |
|-------------|-----------|-------------------------------|-------------------------------|
| Leaf 700    | `#4F654D` | Primary buttons, active states | White text: WCAG 7.2:1 / Lc ~82 — AAA |
| Leaf 500    | `#6C7D67` | Secondary actions, badges      | White text: WCAG 4.9:1 / Lc ~66 — not for small text |
| Moss 300    | `#B7C2B0` | Background fills, hover states |                               |
| Pear 100    | `#F5F2E8` | Cards, surface backgrounds     |                               |
| Ink 900     | `#1E1E1E` | Primary text                   | On Pear: WCAG 15.8:1 / Lc 105+ — AAA |
| Ink 700     | `#444444` | Secondary text                 | WCAG 9.1:1 / Lc 88+          |
| Ink 500     | `#6B6B6B` | Metadata                       | WCAG 5.8:1 / Lc 72+          |
| Parchment   | `#FAF9F6` | Main page background           |                               |
| Focus Blue  | `#2D6CDF` | Focus ring                     | 3px, WCAG compliant           |

### Dark Theme Palette

| Token            | Hex       | Notes                     |
|------------------|-----------|---------------------------|
| Background       | `#141614` |                           |
| Surface          | `#1E221E` |                           |
| Text Primary     | `#F7F6F2` | WCAG 14.8:1 / Lc 104+    |
| Text Secondary   | `#D6D9D2` | WCAG 10.1:1 / Lc 86+     |

### Semantic Colours

| Token       | Hex       | Usage   | White text contrast |
|-------------|-----------|---------|---------------------|
| Success     | `#2E6A44` |         | WCAG 7.1:1 / Lc 80  |
| Warning     | `#8A5B00` |         | WCAG 5.4:1 / Lc 70  |
| Error       | `#A53030` |         | WCAG 6.3:1 / Lc 76  |
| Information | `#1F5A8A` |         | WCAG 7.4:1 / Lc 82  |

### Approved Combinations

| Foreground | Background | ✓ |
|------------|------------|---|
| Ink 900    | Parchment  | ✓ |
| White      | Leaf 700   | ✓ |
| Ink 900    | Pear 100   | ✓ |
| Ink 700    | Parchment  | ✓ |
| White      | Success    | ✓ |

### Prohibited Combinations

| Foreground | Background | Reason |
|------------|------------|--------|
| Leaf 500   | Pear 100   | Fails APCA despite passing portions of WCAG |
| Moss 300   | White      | Fails APCA |
| Ink 500    | Moss 300   | Fails APCA |

---

## 3. Typography

| Role       | Typeface      | Reason                                   |
|------------|---------------|------------------------------------------|
| Logo only  | Caveat        | Brand identity                           |
| Headings   | Fraunces      | Organic, literary, premium, nature-inspired |
| Body       | Inter         | Excellent accessibility, screen readability, variable font |
| Monospace  | JetBrains Mono|                                          |

### Type Scale

| Token      | Size (px) | Line Height (px) |
|------------|-----------|------------------|
| Display    | 64        | 72               |
| H1         | 48        | 56               |
| H2         | 40        | 48               |
| H3         | 32        | 40               |
| H4         | 24        | 32               |
| H5         | 20        | 28               |
| H6         | 18        | 28               |
| Body Large | 18        | 32               |
| Body       | 16        | 28               |
| Small      | 14        | 24               |
| Caption    | 12        | 20               |

### Font Weights

| Usage    | Weight |
|----------|--------|
| Display  | 600    |
| Headings | 600    |
| Body     | 400    |
| Emphasis | 500    |
| Strong   | 600    |

---

## 4. Spacing System

Base unit: **4px**

| Token | Value |
|-------|-------|
| 1     | 4px   |
| 2     | 8px   |
| 3     | 12px  |
| 4     | 16px  |
| 5     | 20px  |
| 6     | 24px  |
| 8     | 32px  |
| 10    | 40px  |
| 12    | 48px  |
| 16    | 64px  |
| 20    | 80px  |
| 24    | 96px  |

### Containers

| Name          | Max Width |
|---------------|-----------|
| Small         | 640px     |
| Medium        | 768px     |
| Large         | 1024px    |
| XL            | 1280px    |
| Reading Width | 72ch      |

### Breakpoints

| Name | Value  |
|------|--------|
| sm   | 640px  |
| md   | 768px  |
| lg   | 1024px |
| xl   | 1280px |
| 2xl  | 1536px |

---

## 5. Iconography

- **Style:** outline only, rounded ends, 1.75px stroke, 24×24 base grid
- **Icons:** Bookmark, Collection, Tag, Archive, Queue, Search
- Never icon-only unless `aria-label` provided
- Never rely on icon colour alone
- Minimum touch target: 44×44px

---

## 6. Illustration System

- **Style:** hand-drawn, single stroke, nature sketchbook
- **Elements:** partridges, pears, leaves, branches, paper, nests
- **Stroke:** 2px (3px for large hero)
- Decorative: `aria-hidden="true"`
- Informative: `role="img" aria-label="..."`

---

## 7. Component Specs

### Primary Button
- Height: 44px minimum, 48px preferred
- Background: Leaf 700 / White text
- Hover: +4% darkness
- Focus: 3px ring `#2D6CDF`
- Disabled: `#CFCFCF`, no opacity reduction below readable levels

### Secondary Button
- Background: transparent
- Border: Leaf 700
- Text: Leaf 700

### Destructive Button
- Background: Error (`#A53030`)
- Text: White

### Input
- Height: 48px
- Border: 2px
- Label always visible — never placeholder-only

### Interactive Controls
- Checkboxes: 24×24px minimum, label click target included
- Radios: 24×24px, visible selected indicator
- Toggles: 52px minimum width, state announced to screen readers
- Dropdowns: ↑↓ Enter Escape Tab keyboard support

### Modals
- Must trap focus, restore focus on close, close on Escape

### Cards
- Minimum padding: 24px
- No hover-only content

### Sidebar
- Minimum width: 280px
- Collapsible but always keyboard accessible

### Tabs
- Arrow keys, Home, End keyboard support

### Toasts
- Never auto-dismiss critical information

### Empty States
- Include: partridge illustration + guidance text + action

### Loading
- Prefer skeletons, avoid spinners beyond 3 seconds

---

## 8. Focus System

```css
outline: 3px solid #2D6CDF;
outline-offset: 2px;
```

- Visible against all surfaces
- Never hidden, never replaced by subtle shadows

### Required Skip Links
- Skip to content
- Skip to navigation
- Skip to search

### Required Landmarks
`<header>`, `<nav>`, `<main>`, `<aside>`, `<footer>`

---

## 9. Motion System

| Purpose         | Duration |
|-----------------|----------|
| Hover           | 100ms    |
| Press           | 75ms     |
| Open            | 150ms    |
| Page transition | 200ms    |

Always respect `prefers-reduced-motion: reduce`:
- Disable: parallax, bounce, scale effects, decorative animation

---

## 10. Responsive Behaviour

| Breakpoint | Layout                            |
|------------|-----------------------------------|
| Mobile     | Single column, 16px margins       |
| Tablet     | Two-column collections            |
| Desktop    | Three-column, persistent sidebar  |
| Ultra-wide | Max reading width retained        |

### Zoom Requirements
- 200%: fully functional, no horizontal scroll
- 400%: single-column reflow, all controls usable

---

## 11. Accessibility Checklist (WCAG 2.2)

**Perceivable:** text alternatives, captions, meaningful sequence, reflow at 400%, contrast AA+, non-text contrast, focus visible

**Operable:** keyboard-only operation, no keyboard trap, target size ≥44×44, dragging alternatives, focus appearance, focus not obscured

**Understandable:** consistent navigation, error prevention, clear labels, accessible authentication

**Robust:** valid semantics, ARIA where needed, screen reader support

### APCA Checklist
- Body text Lc ≥75
- Small text Lc ≥80
- Metadata Lc ≥60
- Icons / borders / focus indicators Lc ≥60
- Dark theme primary text Lc ≥90
- Dark theme secondary text Lc ≥75

### Component Acceptance Gate
A component is not complete until it passes:
- WCAG 2.2 AA minimum
- APCA thresholds
- Keyboard-only navigation
- NVDA + VoiceOver + TalkBack
- Windows High Contrast Mode
- 400% zoom
- Colour blindness simulation
- Reduced motion testing
