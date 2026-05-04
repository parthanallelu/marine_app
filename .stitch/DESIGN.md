# Design System: Manaal's Maritime Tutoring App
**Project ID:** 1369479635686995169

## 1. Visual Theme & Atmosphere

**Creative North Star: "The Polished Academy"**
A premium SaaS-quality maritime tutoring dashboard that balances authority with approachability. Clean, spacious, and professional — like a high-end fintech app for education. Uses generous whitespace, soft depth layers, and a cohesive 8px spacing grid to create rhythm and breathing room across every screen.

**Atmosphere:** Sophisticated, trustworthy, clean minimal. Subtle depth through tonal surface shifts rather than hard borders. Micro-animations on interactive elements (buttons, cards, toggles) for a responsive, alive feel.

---

## 2. Color Palette & Roles

### Light Mode
| Role               | Color     | Description                           |
|--------------------|-----------|---------------------------------------|
| Background         | `#F8FAFC` | Cool off-white canvas                 |
| Card Surface       | `#FFFFFF` | Pure white elevated cards             |
| Primary Action     | `#2563EB` | Vibrant trustworthy blue              |
| Primary Light      | `#DBEAFE` | Soft blue for tinted backgrounds      |
| Text Primary       | `#0F172A` | Deep slate for headings               |
| Text Secondary     | `#475569` | Muted slate for body copy             |
| Text Hint          | `#94A3B8` | Light gray for captions/placeholders  |
| Border             | `#E2E8F0` | Whisper-soft dividers                 |
| Success            | `#16A34A` | Green for positive states             |
| Warning            | `#F59E0B` | Amber for caution states              |
| Error              | `#DC2626` | Red for negative/destructive states   |
| Gold Accent        | `#D4A017` | Premium gold highlights               |

### Dark Mode
| Role               | Color     | Description                           |
|--------------------|-----------|---------------------------------------|
| Background         | `#0F172A` | Deep navy-slate canvas                |
| Card Surface       | `#1E293B` | Elevated dark card surface            |
| Primary Action     | `#60A5FA` | Bright blue for dark contexts         |
| Primary Container  | `#1E3A5F` | Muted blue for tinted backgrounds     |
| Text Primary       | `#E2E8F0` | Light slate for headings              |
| Text Secondary     | `#94A3B8` | Muted for body copy                   |
| Text Hint          | `#64748B` | Dark gray for captions                |
| Border             | `#334155` | Subtle dark dividers                  |
| Success            | `#22C55E` | Bright green for dark mode            |
| Warning            | `#FBBF24` | Bright amber for dark mode            |
| Error              | `#EF4444` | Bright red for dark mode              |
| Gold Accent        | `#F5D77A` | Warm gold highlights                  |

---

## 3. Typography Rules

- **Font Family:** Inter (headings + body) — clean, geometric, highly legible at all sizes
- **Heading Hierarchy:**
  - Display: 32px / Bold (700) — page titles
  - H1: 24px / Bold (700) — section headers
  - H2: 18px / SemiBold (600) — card titles
  - H3: 16px / SemiBold (600) — subsection headers
- **Body Text:**
  - Body Large: 15px / Regular (400)
  - Body Medium: 14px / Regular (400)
  - Body Small: 12px / Regular (400)
- **Labels:**
  - Label Large: 14px / SemiBold (600) — buttons, tabs
  - Label Small: 11px / Medium (500) — badges, captions
- **Letter Spacing:** +0.02em on labels and overlines for professional rigor

---

## 4. Component Stylings

### Cards
- Corner radius: 16px (generously rounded)
- Shadow: `0 4px 16px rgba(15, 23, 42, 0.05)` — whisper-soft navy-tinted
- No hard borders in light mode — depth via tonal background shift
- Dark mode: 0.8px border with `#334155`
- Internal padding: 16px uniform

### Buttons
- Primary: Solid `#2563EB` background, white text, 12px radius, 48px height
- Secondary: Ghost/outlined with primary color border
- Shape: Softly rounded (12px corners)
- Micro-animation: Scale 0.98 on press, 150ms ease

### Status Badges
- **HIGH:** Red background tint (`#FEE2E2`), red text (`#DC2626`), pill-shaped
- **MEDIUM:** Amber background tint (`#FEF3C7`), amber text (`#D97706`), pill-shaped
- **LOW:** Green background tint (`#DCFCE7`), green text (`#16A34A`), pill-shaped
- All badges: 20px corner radius, 6px vertical / 12px horizontal padding

### Bottom Navigation
- Height: 64px
- Background: matches scaffold background
- Active: Primary color icon + bold label
- Inactive: `#94A3B8` muted icon + light label
- Top border: 1px `#E2E8F0` (light) or `#1E293B` (dark)

### Input Fields
- 12px corner radius
- Ghost border: `#E2E8F0` / `#334155`
- Focus state: Primary color border
- 48px height, 16px horizontal padding

---

## 5. Layout Principles

### 8px Grid System
All spacing follows strict 8px multiples:
- `4px` (xxs), `8px` (xs), `12px` (sm), `16px` (md), `20px` (lg), `24px` (xl), `32px` (xxl)
- Screen horizontal padding: 20px
- Card internal padding: 16px
- Section gap: 32px
- Element gap within cards: 8-12px

### Depth Hierarchy (Light Mode)
1. **Base:** `#F8FAFC` background
2. **Elevated:** `#FFFFFF` cards with soft shadow
3. **Floating:** Modals/drawers with elevated shadow

### Depth Hierarchy (Dark Mode)
1. **Base:** `#0F172A` background
2. **Elevated:** `#1E293B` cards with subtle border
3. **Floating:** `#253448` overlays

---

## 6. Screens Inventory

| Screen              | Key Components                              |
|---------------------|---------------------------------------------|
| Home Dashboard      | Stats cards, quick action grid, test tiles  |
| Attendance          | Calendar, progress bar, stat badges         |
| Mock Tests          | Tab bar (3 tabs), test cards, result cards  |
| Study Materials     | Search bar, filter chips, material cards    |
| Interview Prep      | Stat cards, module grid, mock interview list|
| Notice Board        | Announcement cards, priority badges         |
| Side Drawer         | Profile header, menu items, dark mode toggle|
