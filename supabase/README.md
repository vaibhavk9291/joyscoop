# Joyscoop Supabase Setup & Dashboard Guide

## 1. Apply Migration
1. Go to your Supabase project at https://supabase.com/dashboard.
2. Open the **SQL Editor**.
3. Create a **New query**, paste the contents of `supabase/migrations/20261107000000_joyscoop_init.sql`, and click **Run**.
4. Confirm tables (`products`, `sales_events`, `profiles`), views (`daily_summary`, `daily_totals`), and triggers are created.

---

## 2. Supabase Dashboard Steps

### A. Disable Public Signups
1. Go to **Authentication** -> **Configuration** / **Providers** -> **Email**.
2. Turn **Confirm email** OFF (or ON based on your preference; OFF allows immediate login with provisioned passwords).
3. Under **Authentication Settings** (or User Management):
   - Uncheck / Disable **"Enable Signups"** (or "Allow new users to sign up").
   - This ensures only the shop owner/admin can add the 4 staff users.

### B. Create the 4 Staff Users
1. In the Supabase Dashboard, go to **Authentication** -> **Users**.
2. Click **Add user** -> **Create user** (email + password) for each of the 4 staff members:
   - `staff1@joyscoop.shop`
   - `staff2@joyscoop.shop`
   - `staff3@joyscoop.shop`
   - `staff4@joyscoop.shop`
3. Copy each created user's `UUID`.

### C. Populate Profiles
In the **SQL Editor**, run:
```sql
insert into public.profiles (id, display_name)
values
  ('<UUID-OF-STAFF-1>', 'Aarav'),
  ('<UUID-OF-STAFF-2>', 'Diya'),
  ('<UUID-OF-STAFF-3>', 'Rohan'),
  ('<UUID-OF-STAFF-4>', 'Pooja')
on conflict (id) do update set display_name = excluded.display_name;
```

### D. Verify Realtime is Enabled
1. Go to **Database** -> **Replication** (or Publications).
2. Verify that `supabase_realtime` publication includes the `sales_events` table (the SQL migration executes `alter publication supabase_realtime add table public.sales_events;`).

---

## 3. Test Queries

See `supabase/test_queries.sql` to verify calculations and trigger safety.

