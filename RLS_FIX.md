# Fix Supabase Permission Errors ("Error loading offers/categories/best sellers")

## Problem
Your app shows "Error loading offers/categories/best sellers" because the `products` and `categories` tables have **Row Level Security (RLS) enabled** without read policies.

## Solution: Run This SQL in Supabase

### Step 1: Open Supabase Dashboard
1. Go to https://app.supabase.com
2. Select your project
3. Go to **SQL Editor** on the left sidebar

### Step 2: Run This SQL to Fix Permissions

**Option A: Simplest (Disable RLS)** – Use this if you don't need row-level security:
```sql
ALTER TABLE categories DISABLE ROW LEVEL SECURITY;
ALTER TABLE products DISABLE ROW LEVEL SECURITY;
```

**Option B: Recommended (Create Read Policies)** – Use this for production:
```sql
-- Enable RLS if not already enabled
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- Create a policy to allow public SELECT on categories
CREATE POLICY "Allow public select on categories"
ON categories
FOR SELECT
USING (true);

-- Create a policy to allow public SELECT on products
CREATE POLICY "Allow public select on products"
ON products
FOR SELECT
USING (true);
```

### Step 3: Verify
1. After running the SQL, go to **Authentication > Policies** in Supabase
2. Select `categories` table → you should see the policy
3. Select `products` table → you should see the policy
4. RLS Status should show as "ON" (if using Option B) or "OFF" (if using Option A)

### Step 4: Re-run Your Flutter App
```bash
flutter run -d <device-id>
```

The "Error loading ..." messages should now be replaced with actual product/category data.

## Troubleshooting

**Still seeing errors?**
- Check the Supabase logs: Dashboard → **Logs** → look for request errors
- Verify table names are exactly `categories` and `products` (lowercase, no typos)
- Verify your app's Supabase URL and key in `lib/main.dart` match your project

**To check table structure:**
```bash
# In Supabase, go to SQL Editor and run:
SELECT * FROM categories LIMIT 1;
SELECT * FROM products LIMIT 1;
```

If both queries return data, then your RLS policies are working correctly.
