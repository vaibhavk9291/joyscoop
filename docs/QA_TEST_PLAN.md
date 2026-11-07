# Joyscoop: Multi-Device QA Test Plan

## Scenario 1: Concurrency & Realtime Synchronization (3 Devices)
*Setup*: Log in as Staff 1 (Device A), Staff 2 (Device B), and Staff 3 (Device C).

1. **Simultaneous Increments**:
   - Device A, B, and C tap `+` on "Softy" within 1 second.
   - **Expected**: All 3 devices reflect `3` softies sold and total revenue `₹90` within ~1 second. No sales are overwritten or dropped.
2. **Instant Optimistic Feedback**:
   - Device A taps `+` on "Cold Coffee with Vanilla".
   - **Expected**: Device A updates count instantly without visual lag or spinner; server confirmation completes in background.
3. **Undo Safeguard**:
   - Device A taps "Undo last tap".
   - **Expected**: Device A subtracts 1 from "Cold Coffee with Vanilla". Devices B and C receive the event and update counts automatically.

---

## Scenario 2: Offline Resilience & Reconnection
*Setup*: Device B turns on Airplane Mode (Offline).

1. **Offline Queuing**:
   - Device B turns off WiFi / Cellular. Header chip turns grey ("Offline").
   - Device B taps `+` on "Cold Coffee" twice. Header chip displays "Offline (2)".
   - Device B closes the app and reopens it.
   - **Expected**: Taps are persisted in `SharedPreferences` and count remains pending.
2. **Online Drain & Reconciliation**:
   - Device B turns WiFi back on.
   - **Expected**: App detects connectivity, drains queue in FIFO order, chip switches to "Live", and server reconciles totals across all devices.

---

## Scenario 3: Business Date Rollover
*Setup*: Shop operating past 11:30 PM into midnight IST.

1. **Midnight Rollover Check**:
   - Device stays open through 12:00:00 AM IST.
   - **Expected**: Date monitor detects change from previous day's calendar date to new date, resets current counter to 0 for the fresh day, and clears prior undo history. Previous day's total is viewable under "History".

---

## Scenario 4: History & Summary Report Share
1. **7-Day Trend**:
   - Open History tab.
   - **Expected**: 7-day revenue bar chart renders with blush gradient bars and current day highlighted.
2. **Day Detail Breakdown**:
   - Tap any day card.
   - **Expected**: Bottom sheet opens with radius 32, product breakdown (units and revenue), and bold grand total.
3. **Report Share**:
   - Tap "Share today's report".
   - **Expected**: System share sheet opens with formatted text summary ready to send via WhatsApp, SMS, or Email.

