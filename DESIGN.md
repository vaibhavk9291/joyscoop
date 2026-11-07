# Joyscoop UI Design System

Reference: soft pink "ice cream shop" mobile UI (home, details, cart screens). Light theme only. The goal is to match that look in Flutter. Colors are approximated from the reference image, so treat the hex values as the source of truth for the app.

## 1. Mood
Soft, sweet, airy, premium. Blush-pink gradient backgrounds, white floating cards, glowing pink gradient buttons, very rounded shapes, generous whitespace. Nothing sharp, no hard borders, no heavy dividers.

## 2. Color tokens

| Token | Hex | Use |
|---|---|---|
| bgTop | #FFE3EA | Top of screen gradient |
| bgMid | #FFF1F4 | Middle of gradient |
| bgBottom | #FFFFFF | Bottom of gradient |
| surface | #FFFFFF | Cards, circular icon buttons, nav bar |
| surfaceMuted | #F4F4F6 | Secondary button (like "Add to Cart"), disabled stepper |
| primary | #F2476A | Primary actions, active icons, highlights |
| primaryLight | #FF7A93 | Gradient start for primary buttons |
| primaryTint | #FFD9E2 | Active nav circle, soft chips, tinted thumbnails |
| textPrimary | #1F1F24 | Titles, prices |
| textSecondary | #8A8A93 | Subtitles, captions, labels |
| danger | #E5486B | Negative values (like discount / minus totals) |
| ratingStar | #FFB020 | Star icons if used |

Gradients:
- Screen background: vertical, bgTop -> bgMid -> bgBottom.
- Primary button / hero card: horizontal-diagonal, primaryLight -> primary.

Product accent tints (used for thumbnail backgrounds and the + button halo):
- Softy: #FFD9E2
- Cold Coffee: #F3E1D0
- Cold Coffee with Crush: #FFD0DA
- Cold Coffee with Vanilla: #FFF1CC

## 3. Typography
Font: **Plus Jakarta Sans** (via google_fonts). Fallback: Poppins.

| Style | Size / Weight | Use |
|---|---|---|
| displayPrice | 32 / 800 | Hero revenue amount |
| title | 20 / 700 | Screen titles |
| sectionTitle | 18 / 700 | "Categories", "Products" style headers |
| cardTitle | 16 / 700 | Product name |
| body | 14 / 500 | General text |
| caption | 12 / 500, textSecondary | Subtitles, units, labels |
| button | 16 / 700 | Buttons |

Prices use the ₹ symbol, no decimals, bold, textPrimary.

## 4. Shape, spacing, elevation
- Screen horizontal padding: 20
- Spacing scale: 4, 8, 12, 16, 20, 24, 32
- Card radius: 24
- Pill button radius: 28 (fully rounded, height 56)
- Thumbnail radius: 20
- Circular icon button: 44x44, white, radius 22
- Bottom sheet top radius: 32
- Shadow (cards): color #F2476A at 12% opacity, blur 24, offset (0, 8)
- Shadow (circular buttons): color #000 at 6% opacity, blur 12, offset (0, 4)
- Primary button glow: color #F2476A at 35% opacity, blur 20, offset (0, 8)
- No borders anywhere except a 1px #F0E4E8 hairline if a divider is unavoidable.

## 5. Components

**Circular icon button**: white circle, soft shadow, dark 20px outline icon. Used for logout, sync status, back, share.

**Pill search/date bar**: white, fully rounded, height 48, leading icon, textSecondary hint. Used as the date selector on History.

**Primary button**: pink gradient, white bold text, pill shape, glow shadow. Used for "Share today's report" and "Sign in".

**Secondary button**: surfaceMuted, textPrimary text, pill shape, no shadow.

**Quantity stepper**: row of [ - ] count [ + ]. The minus is a 36px white circle with a soft shadow and dark icon. The plus is a 36px pink gradient circle with a white icon. The count is 16 / 700 between them. At 0, minus is surfaceMuted with a grey icon and is disabled. For one-handed shop use, the tap target must be at least 48x48 even though the visual circle is 36 to 44.

**Product row card (cart-item style)**: white card, radius 24, padding 12. Left: 72x72 thumbnail with tinted background and radius 20. Middle: product name (cardTitle), price as caption ("₹30 each"), and below it "Today: ₹X" in danger-free textSecondary. Right: the quantity stepper. Cards are separated by 12 spacing.

**Hero summary card (home)**: full-width card, radius 28, pink gradient background, white text. Shows "Today's Sales" caption, the revenue in displayPrice, and a second line "N items sold". A subtle decorative circle (white at 12% opacity) in the top-right corner.

**Summary bottom sheet (History day detail)**: white sheet with top radius 32, rows with label left (textSecondary) and value right (textPrimary, bold), the grand total row in bold, and a primary gradient button underneath. Negative values in danger.

**Floating bottom navigation**: floating pill, white, radius 36, horizontal margin 40, bottom margin 16, soft shadow. Two items (Today, History), each a 48px circle. Active item has a primaryTint circle with a primary icon. Inactive is a textSecondary outline icon.

**Live indicator chip**: small pill, white, with a 8px dot. Green dot = Live, grey = Offline, plus a pending count when queued.

**Header (home)**: left avatar circle (40) with greeting "Hey, {name}" (caption) over "Good Morning/Afternoon/Evening" (cardTitle). Right: live chip and circular logout button.

## 6. Screens

**Login**: gradient background, Joyscoop logo centered at the top (assets/branding/logo.png), title "Welcome back", a white rounded email field and password field (radius 28, no border, soft shadow), primary pill "Sign in".

**Today (home)**: header, hero summary card, section title "Products", the 4 product row cards, then bottom padding so the floating nav never overlaps content. An "Undo last tap" secondary pill sits just above the nav.

**History**: header with title "History", a pill date selector, a 7-day revenue bar chart in a white card (bars in primary gradient, rounded tops, current day highlighted), week and month summary chips, then a list of day cards (date, items, revenue). Tapping a day opens the summary bottom sheet with the per-product breakdown.

## 7. Motion
- Tap on + / -: scale to 0.92 and back over 120 ms, with a light haptic.
- Count change: AnimatedSwitcher with a short slide and fade (180 ms).
- Hero revenue number: animated count-up on change (300 ms).
- Screen transitions: fade + slight upward slide (250 ms).
- Loading: shimmer skeletons in blush tones, not grey.

## 8. Imagery
Product thumbnails sit on tinted rounded squares. Until real product photos are supplied, use clean illustrated icons or placeholder assets in assets/products/ named softy.png, cold_coffee.png, cold_coffee_crush.png, cold_coffee_vanilla.png. Keep the asset slots so photos can be dropped in without code changes.

## 9. Rules
- Light theme only. Do not add a dark mode.
- Use Material 3 as the base, but override every component with the tokens above.
- No default Material blue or purple anywhere.
- Never use hard borders, sharp corners, or full-black text.
- All tokens live in core/theme (colors.dart, text_styles.dart, theme.dart, gradients.dart). No hardcoded colors or sizes inside widgets.
