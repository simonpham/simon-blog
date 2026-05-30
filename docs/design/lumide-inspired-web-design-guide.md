# Lumide-Inspired Web Design Guide

This guide describes the UI direction for a web implementation that should feel visually aligned with Lumide IDE and the Simon blog redesign. It is written for Tailwind CSS implementation, but the principles are framework-agnostic.

## Design Intent

The interface should feel like a quiet desktop tool, not a marketing website. Use compact controls, restrained contrast, rounded island panels, subtle hover states, and a muted neutral palette with a warm orange accent.

Avoid large hero sections, decorative gradients, oversized cards, heavy shadows, and bright saturated surfaces. The main experience should look like a polished IDE/workbench for reading and browsing posts.

## Color Palette

Use the Ailurus palette.

### Light Theme

```css
--primary: #D65D2E;
--secondary: #6CA1B8;
--neutral-1: #EFEBE3;
--neutral-2: #F8F6F1;
--neutral-3: #E4DED4;
--neutral-4: #889096;
--neutral-5: #6C7275;
--neutral-6: #2A2F33;
--neutral-7: #141718;
```

Recommended semantic mapping:

```css
--app-bg: var(--neutral-1);
--panel-bg: var(--neutral-2);
--panel-muted: var(--neutral-3);
--text: var(--neutral-7);
--text-muted: color-mix(in srgb, var(--neutral-7) 50%, transparent);
--divider: var(--neutral-3);
--accent: var(--primary);
```

### Dark Theme

```css
--primary: #D65D2E;
--secondary: #6CA1B8;
--neutral-1: #E4E1DB;
--neutral-2: #F3F5F7;
--neutral-3: #E8ECEF;
--neutral-4: #6C7275;
--neutral-5: #343839;
--neutral-6: #171B1E;
--neutral-7: #0B0B0B;
```

Recommended semantic mapping:

```css
--app-bg: var(--neutral-7);
--panel-bg: var(--neutral-6);
--panel-muted: var(--neutral-5);
--text: var(--neutral-1);
--text-muted: color-mix(in srgb, var(--neutral-1) 50%, transparent);
--divider: var(--neutral-4);
--accent: var(--primary);
```

## Typography

Use:

- UI font: `Nunito`
- Article/content font: `Lora`
- Code/editor font: `JetBrains Mono`
- Comment terminal-style section: `Iosevka`

Tailwind example:

```js
fontFamily: {
  sans: ['Nunito', 'ui-sans-serif', 'system-ui'],
  serif: ['Lora', 'ui-serif', 'Georgia'],
  mono: ['JetBrains Mono', 'ui-monospace', 'SFMono-Regular'],
  comment: ['Iosevka', 'ui-monospace', 'SFMono-Regular'],
}
```

Default UI text should be compact. Most workbench text should sit around `12px-14px`; avoid marketing-sized text in panels and toolbars.

## Spacing Scale

Use a 4px-based scale.

```css
--space-1: 4px;
--space-2: 8px;
--space-3: 12px;
--space-4: 16px;
--space-5: 20px;
--space-6: 24px;
--space-8: 32px;
```

Important dimensions:

- Top bar height: `36px`
- Status bar height: `24px`
- Pane tab bar height: `48px`
- Pane tab item height: `28px`
- File tree row height: `24px`
- Main layout island gap: `8px`
- Pane resizer visual gap: `8px`

## Corners: Continuous Rounded Rectangles / Squircles

The rounded borders are not regular CSS rounded rectangles. Lumide uses Flutter smooth corners, visually closer to Apple-style continuous rounded rectangles / squircles.

Use regular `border-radius` only as a fallback. For a closer web match, use a squircle/continuous-corner implementation.

- Main island panels: `12px`
- Pane tab items: `8px`
- File tree selected rows: `8px`
- Search/dialog shell: `12px`
- Small logo mark: `6px`

### Preferred Web Options

Option A: CSS `clip-path` / SVG squircle mask for key containers.

Use this for:

- Main island panels
- Dialog shell
- Active/hover tab items
- File tree selected rows
- Search/result rows if they have visible rounded fill

Option B: Use a squircle utility/plugin.

Good implementation targets:

- `corner-smoothing: 1.0` equivalent if using a design-token/plugin system.
- Figma squircle/continuous corner approximation.
- Superellipse/squircle mask with radius token.

Option C: Plain Tailwind fallback.

```html
rounded-xl  /* 12px */
rounded-lg  /* 8px */
rounded-md  /* 6px */
```

Plain `border-radius` is acceptable for first pass, but the final visual target should be continuous corners. Do not use pill-shaped tabs/buttons unless they are very small icon controls.

### CSS Example

A practical fallback-friendly approach:

```css
.squircle-panel {
  border-radius: 12px;
}

@supports (clip-path: path("M 0 0")) {
  .squircle-panel {
    border-radius: 0;
    clip-path: path("M 12 0 H calc(100% - 12px) C calc(100% - 5px) 0 100% 5px 100% 12px V calc(100% - 12px) C 100% calc(100% - 5px) calc(100% - 5px) 100% calc(100% - 12px) 100% H 12px C 5px 100% 0 calc(100% - 5px) 0 calc(100% - 12px) V 12px C 0 5px 5px 0 12px 0 Z");
  }
}
```

If this is too brittle for responsive containers, use SVG masks or a small squircle React/Tailwind utility instead. The important visual rule is: corners should feel continuous and Apple-like, not circular arcs.

## App Layout

The page is an IDE-like workbench:

```text
TopBar 36px
Main area with island panels and 8px gaps
StatusBar 24px
```

The main area should have:

- `8px` left/right/bottom padding.
- No divider below the top bar.
- Transparent pane gaps/resizers so the app background shows between rounded island panels.
- Rounded panel backgrounds applied by the panel container itself. Avoid child elements painting full square backgrounds over panel corners.

Tailwind sketch:

```html
<div class="h-screen bg-[var(--app-bg)] text-[var(--text)] font-sans">
  <header class="h-9"></header>
  <main class="h-[calc(100vh-60px)] px-2 pb-2">
    <div class="grid h-full gap-2">
      <section class="squircle-panel bg-[var(--panel-bg)]"></section>
      <section class="squircle-panel bg-[var(--panel-bg)]"></section>
    </div>
  </main>
  <footer class="h-6"></footer>
</div>
```

## Top Bar

Top bar style:

- Height: `36px`
- Background: app background, not panel background.
- Center: brand/logo.
- Left: pane toggle icons.
- Right: `Try Lumide` promo link and search icon.
- No bottom border.
- Use very thin vertical dividers between left/center/right groups.

Divider:

```css
width: 0.25px;
height: 20px;
background: color-mix(in srgb, var(--text) 50%, transparent);
```

Pane toggle buttons:

- Icon size: `16px`
- Padding: `4px`
- Foreground: `onSurface`/text color, same color for all toggles.
- Hover: subtle overlay only. Do not tint active/inactive differently.

Promo link:

- Text: `Try Lumide`
- Link: `https://lumide.dev`
- Keep it compact in the right toolbar group.
- Text/icon color: `text` at roughly `72%` opacity.

## Status Bar

Status bar style:

- Height: `24px`
- Background: panel/surface color, not muted surface.
- Top border: `1px` divider.
- Horizontal padding: `12px`
- Foreground: text color at roughly `50%` opacity.
- Font size: `11px`
- Font weight: `500`

Avoid placing pane toggles in the status bar. Pane toggles belong in the top bar.

## Island Panels

Panel container:

- Background: panel surface.
- Radius: `12px`.
- No heavy shadow.
- Children should not paint square full-panel backgrounds.
- If a child needs a header or footer border, use only a divider line, not a full different rectangular background unless it is inside the rounded panel safely.

Do:

```html
<section class="squircle-panel bg-[var(--panel-bg)] overflow-hidden">
  ...
</section>
```

Do not place floating card sections inside panels unless they are repeated list items or dialogs.

## Pane Tabs

Pane tab bar:

- Height: `48px`
- Transparent background; it sits on panel background.
- Left padding: `8px`
- Gap between tab items: `8px`

Pane tab item:

- Height: `28px`
- Max width: `200px`
- Radius: `8px`
- Border: `1px solid primary` when active, transparent otherwise.
- Background: primary at `10%` alpha for active or hovered tab.
- Icon size: `14px`
- Text style: compact body text.
- Active text: full text color.
- Inactive text: text at `50%` opacity.

Tailwind sketch:

```html
<div class="flex h-12 items-center gap-2 pl-2">
  <button class="flex h-7 max-w-[200px] items-center rounded-lg border border-[var(--accent)] bg-[color-mix(in_srgb,var(--accent)_10%,transparent)] px-2">
    <span class="size-3.5"></span>
    <span class="ml-1 truncate text-xs">Post title</span>
  </button>
</div>
```

## Blog File Tree

This tree is for blog browsing, not filesystem management. Match Lumide behavior where it makes sense:

- Categories behave like folders.
- Posts behave like files.
- Categories can expand/collapse.
- Posts are indented under categories.
- Draw continuous indent guides for expanded category children.
- Support horizontal scrolling for long category/post names.
- Row height: `24px`.
- Indent size: `20px`.
- Row left inset: `8px`.
- Icon size: `16px`.
- Icon/text gap: `4px`.
- Hover/selected background: primary at `15%` alpha.
- Text/icon color: text at `87%` opacity.

Avoid:

- Uppercasing category names.
- Bold category labels.
- Tinting selected icons orange.
- Large vertical gaps between categories and posts.

## Search Dialog

The search dialog should keep a command-palette-like floating position:

- Top centered.
- Top offset: about `20vh`.
- Width: `600px`.
- Side padding on small screens: `16px`.
- Background: app background.
- Radius: `12px`.
- Border: `0.25px` divider.
- No heavy shadow.

Input:

- Prefix search icon.
- Padding: `16px`.
- No visible input box decoration inside the dialog shell.

Results:

- Hover/selected background: primary at `10%` alpha.
- Result row padding: `16px` horizontal, `12px` vertical.

## Markdown Content

Article/content area:

- Use `Lora`.
- Full panel width, not constrained to a centered article card.
- Outer content padding: `24px`.
- Do not add an inner card/border around the article.

Code:

- Use `JetBrains Mono`.
- Code block background should be different from panel background.
- Current mapping:
  - Light: `neutral3`
  - Dark: `neutral5`
- Code block radius: `8px`.
- Code block padding: `12px`.
- Inline code background: primary at `12%` alpha.
- `pre` and `pre code` must share the same background.

## Chat And Comments

Chat:

- Input should not paint a square full-width background over panel rounded corners.
- Use only a top divider and transparent/panel-owned background.
- Chat bubbles should stand out from the panel:
  - Incoming: muted panel color.
  - Outgoing: primary at low alpha.

Comments:

- Keep `Iosevka`.
- Treat it like a compact terminal/comment feed.
- Do not inherit the global `Nunito` UI font inside the comment panel.

## Interaction States

Use subtle states:

- Hover row/tab: primary at `10%-15%` alpha.
- Selected row: primary at `15%` alpha.
- Disabled/inactive text: text at `50%` opacity.
- Secondary/metadata text: text at `50%-72%` opacity depending on importance.
- File tree normal foreground: text at `87%` opacity.
- Section/header labels inside utility panes: text at `40%-50%` opacity, `11px`.

Avoid strong shadows, dark overlays, or high-saturation hover fills.

## Motion And Hover Overlay

Lumide interactions are fast and quiet. Use short transitions and avoid bouncy motion.

Recommended defaults:

- Hover/press transition duration: `75ms`.
- Hover overlay uses primary color at `10%` alpha.
- Focus overlay can be primary at `20%` alpha or a thin focus border.
- Pressed state can scale down very slightly, around `0.975`.
- Hover scale, if used, should be very slight, around `1.025`.

For web, it is acceptable to skip scale animation on dense lists and keep only color transitions:

```html
transition-colors duration-75
hover:bg-[color-mix(in_srgb,var(--accent)_10%,transparent)]
```

Use hover overlays for toolbar buttons and small icon buttons. For file tree rows and tabs, use direct background color changes instead of separate visible button chrome.

## Icons

Use Lucide-style line icons or similarly thin, rounded stroke icons. The exact icon set matters less than consistency.

Sizing:

- Toolbar icons: `16px`
- Pane tab icons: `14px`
- Status bar icons: `14px`
- File tree icons: `16px`
- Copy/close micro icons: `12px`

Color:

- Default toolbar icons: full text color.
- File tree icons: text color at `87%` opacity.
- Pane tab icons: text color at `70%` opacity.
- Metadata/status icons: text color at `50%` opacity.

Avoid mixing filled emoji-style icons with outline toolbar icons. If the web version cannot use Lumide's exact icons, use Lucide equivalents and keep stroke width consistent.

## Dividers

Dividers are intentionally quiet.

- Top bar section dividers: `0.25px`, `20px` tall, text/onSurfaceVariant at `50%` opacity.
- Status bar top divider: `1px`, normal divider color.
- Panel internal dividers: `1px`, normal divider color.
- File tree indent guides: `1px`, divider color at `20%` opacity.

Do not add a divider directly below the top bar.

## Scrollbars

Scrollbars should feel native or very quiet.

For file tree horizontal overflow:

- Only allow horizontal scrolling when the content is wider than the panel.
- Do not create a large empty horizontal scroll area.
- Keep long names single-line with `white-space: nowrap`.
- Prefer hidden/fading scrollbars until active.

If custom scrollbars are used:

- Thumb idle alpha around `25%`.
- Thumb hover/active alpha around `50%`.
- No bright track.

## Drag Feedback

If the web version adds drag interactions later, match Lumide's feedback:

- Drag preview background: panel muted/surface container.
- Radius: `8px` continuous corner.
- Padding: `12px` horizontal.
- Shadow: small, soft, black at about `20%`, blur `8px`, y-offset `4px`.
- Original row opacity while dragging: `50%`.

Do not add drag styling to the blog tree unless drag is actually implemented.

## Empty States

Empty states should still feel like an app panel, not a marketing hero.

Use:

- Centered content.
- Icon size around `32px-48px`.
- Accent tint around `5%-10%`.
- Body text at `50%` opacity.
- Compact action tiles, not big cards.

Avoid illustration-heavy or gradient empty states.

## Tailwind Component Recipes

### Toolbar Icon Button

```html
<button
  class="grid size-6 place-items-center text-[var(--text)] transition-colors duration-75 hover:bg-[color-mix(in_srgb,var(--accent)_10%,transparent)]"
>
  <Icon class="size-4" />
</button>
```

Use a squircle/continuous-corner utility for the hover background if the button has a visible fill.

### Pane Island

```html
<section class="squircle-panel bg-[var(--panel-bg)] overflow-hidden">
  <div class="h-12 flex items-center gap-2 pl-2">
    ...
  </div>
  <div class="min-h-0 flex-1 overflow-auto">
    ...
  </div>
</section>
```

### File Tree Row

```html
<button
  class="h-6 w-full whitespace-nowrap text-left transition-colors duration-75 hover:bg-[color-mix(in_srgb,var(--accent)_15%,transparent)]"
>
  <span class="ml-2 inline-flex items-center gap-1 text-[color-mix(in_srgb,var(--text)_87%,transparent)]">
    <Icon class="size-4" />
    <span>post-name.md</span>
  </span>
</button>
```

### Status Bar Item

```html
<span class="inline-flex h-6 items-center gap-1 px-1.5 text-[11px] font-medium text-[color-mix(in_srgb,var(--text)_50%,transparent)]">
  Markdown
</span>
```

## Tailwind Theme Starter

```js
export default {
  theme: {
    extend: {
      fontFamily: {
        sans: ['Nunito', 'ui-sans-serif', 'system-ui'],
        serif: ['Lora', 'ui-serif', 'Georgia'],
        mono: ['JetBrains Mono', 'ui-monospace', 'SFMono-Regular'],
        comment: ['Iosevka', 'ui-monospace', 'SFMono-Regular'],
      },
      borderRadius: {
        panel: '12px',
        control: '8px',
        mark: '6px',
      },
      spacing: {
        4.5: '18px',
      },
    },
  },
};
```

Prefer CSS variables for colors so light/dark theme switching stays simple.

## Quick QA Checklist

- Top bar has no bottom divider.
- Brand/logo is centered.
- Pane toggles are in the top bar, same foreground color.
- Main panels are rounded islands with `8px` gaps.
- Status bar background matches panel surface and uses muted foreground.
- Pane tab bars are transparent on panel background.
- File tree rows are compact and horizontally scrollable only when content needs it.
- Markdown code blocks use a visibly distinct background.
- Comments retain Iosevka, article content retains Lora, code retains JetBrains Mono.
- Hover transitions feel immediate, around `75ms`.
- Icons use consistent thin-line styling and the correct size for their area.
- Dividers are subtle; top-bar dividers are thinner than panel/status dividers.
- Horizontal scrolling appears only when content requires it.
