# Joyscoop: Build Prompts (4 phases)

App: **Joyscoop**, a daily sales counter for a softy and cold coffee shop.
Shop hours: 12:00 PM to 11:30 PM IST (business date = IST calendar date, so no midnight edge case).
Users: 4 individual logins created manually in Supabase.
Design: follow DESIGN.md exactly (put it in the project root as docs/DESIGN.md and attach it to every prompt).

---

## Phase 1: Supabase backend

```
You are a senior backend engineer. Set up the Supabase backend for "Joyscoop", a small daily sales counter app for a softy ice cream and cold coffee shop.

Products (fixed, price in INR):
- Softy: 30
- Cold Coffee: 40
- Cold Coffee with Crush: 50
- Cold Coffee with Vanilla: 60

Write one SQL migration file that creates:
1. `products` table: id (uuid pk), name, price (integer), sort_order, is_active (default true). Seed the 4 products above.
2. `sales_events` table, append-only: id (uuid pk), product_id (fk), delta (smallint, only +1 or -1 via check constraint), unit_price (integer, copied from the product at insert time via trigger), business_date (date, default (now() at time zone 'Asia/Kolkata')::date), created_by (uuid, default auth.uid()), created_at (timestamptz default now()).
3. A trigger that blocks any -1 event if it would make that product's total for that business_date go below zero.
4. A view `daily_summary` (business_date, product_id, product_name, units_sold, revenue) and a view `daily_totals` (business_date, total_units, total_revenue). Both sum delta and delta * unit_price.
5. A `profiles` table: id (uuid pk, references auth.users), display_name. Used for the greeting in the app.
6. Row Level Security: only authenticated users can select from products, sales_events and profiles, and insert into sales_events. No updates or deletes on sales_events.
7. Enable Realtime on `sales_events`.

Auth: email/password, 4 users created manually in the Supabase dashboard (no public signup). Business hours are 12 PM to 11:30 PM IST, so the IST business_date default is correct.

Output: the full SQL, a short checklist of dashboard steps (disable signups, create the 4 users and insert their display names into profiles, enable realtime), and 3 test queries to verify the totals.
```

---

## Phase 2: Flutter foundation, design system, and Today screen

```
You are a senior Flutter engineer. Build the first version of "Joyscoop", a daily sales counter for a softy ice cream and cold coffee shop.

Stack: Flutter (latest stable), supabase_flutter, Riverpod, google_fonts, feature-first folders (core/, features/auth, features/counter).

IMPORTANT: The attached DESIGN.md is the single source of truth for the UI. Reproduce it exactly: the pink gradient background, white rounded cards, pill buttons with glow, circular icon buttons, the stepper with a white minus circle and a pink gradient plus circle, the hero summary card, and the floating pill bottom navigation. Light theme only. Put every color, gradient, text style, radius and shadow into core/theme as tokens, and use only those tokens in widgets. No hardcoded values.

Backend (already built): tables `products`, `sales_events`, `profiles`, and views `daily_summary` and `daily_totals`. Each "+" tap inserts a row into sales_events with delta = +1, each "-" inserts delta = -1.

Build:
1. Supabase initialization using environment config (no hardcoded keys), with a persisted session.
2. Login screen exactly as described in DESIGN.md (logo at assets/branding/logo.png, rounded fields, pill "Sign in"). Auto-redirect if signed in. Logout via the circular icon button in the header.
3. Today screen exactly as described in DESIGN.md: header with avatar and a time-based greeting using the profile display_name, the hero gradient summary card (today's revenue in ₹ and items sold), then 4 product row cards (thumbnail, name, price, "Today: ₹X", stepper). The "-" is disabled at 0. Tap targets at least 48x48. Haptic feedback on tap and the tap scale animation from DESIGN.md.
4. Floating pill bottom navigation (Today | History) with the History tab as an empty placeholder for now.
5. Product thumbnails from assets/products/ with the tinted backgrounds, using simple placeholders until real images are added.

Rules: small reusable widgets, loading and error states, ₹ formatting with no decimals, and load data with a simple fetch on screen open (realtime comes in the next phase).

Output the complete code for every file, plus pubspec.yaml (including assets and fonts) and run instructions.
```

---

## Phase 3: Realtime sync and reliability

```
Continue the Flutter app "Joyscoop". Phase 2 is complete. Keep following DESIGN.md for every new UI element.

1. Realtime: subscribe to Supabase Realtime on `sales_events`. When any of the 4 users' devices inserts an event, every open device updates its product counts, total items and total revenue within about a second, with no manual refresh. Derive state from the `daily_summary` view and re-fetch on each realtime event (or apply the delta locally and reconcile).
2. Optimistic UI: tapping + or - updates the screen instantly, then confirms with the server. On failure, roll back and show a styled snackbar (white, rounded, danger accent).
3. Concurrency: simultaneous taps from several phones must never lose a sale. Never overwrite counts, only insert events.
4. Live / Offline chip in the header (as in DESIGN.md). If offline, queue taps locally (persisted), sync them in order when the connection returns, and show a pending count on the chip.
5. Date rollover: the shop closes at 11:30 PM, but if the app stays open past midnight IST, switch to the new business date automatically.
6. "Undo last tap" secondary pill button: inserts a compensating +1 or -1 for the current user's most recent event.
7. Animate the hero revenue as a count-up and the product counts with the AnimatedSwitcher from DESIGN.md.

Provide updated code for changed files only, plus a manual test plan using 3 devices.
```

---

## Phase 4: History, reports, branding, release

```
Continue the Flutter app "Joyscoop". Phases 2 and 3 are complete. Keep following DESIGN.md exactly.

1. History screen (second tab): header, pill date selector, a 7-day revenue bar chart in a white card (gradient bars with rounded tops, today highlighted), week and month summary chips, and a list of day cards (date, total items, revenue) for the last 30 days. Tapping a day opens the summary bottom sheet from DESIGN.md with the per-product breakdown (units and revenue) and a grand total.
2. Share: a primary gradient pill button "Share today's report" that sends a plain-text summary (date, each item with count and revenue, grand total) through the system share sheet, for example to WhatsApp.
3. Polish: empty states, blush-toned shimmer skeletons, pull-to-refresh, consistent animations from DESIGN.md, tablet-safe layout, large-text accessibility.
4. Branding: use the provided logo (assets/branding/logo.png) for the app icon (flutter_launcher_icons, including the Android adaptive icon with a #FFE3EA background), the splash screen (flutter_native_splash, blush gradient background with the centered logo), and the login screen.
5. Release: Android release signing steps, building an APK for the shop phones, and a short checklist for Supabase production settings (backups, RLS verification, key handling).

Output changed code, the release steps, and a final QA checklist.
```
