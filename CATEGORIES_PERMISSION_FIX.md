# Supabase Categories Permission Fix

## Problem
Your `categories` table has Row Level Security (RLS) enabled but lacks a SELECT policy for authenticated users.

Error message:
```
permission denied for table categories, code: 42501
Grant the required privileges to the current role with: 
GRANT SELECT ON public.categories TO authenticated;
```

## Solution

Go to your Supabase dashboard → **SQL Editor** → run this SQL:

```sql
-- Grant SELECT permission on categories table to authenticated users
GRANT SELECT ON public.categories TO authenticated;

-- Alternatively, if you want public (anonymous) access:
GRANT SELECT ON public.categories TO anon;

-- Or if you're using a service role or specific user, replace 'authenticated' with the role name
```

**After running the SQL**, reload your Flutter app:
```bash
flutter run -d 00008150-001603600A00401C
```

## What This Does
- Allows authenticated users (logged-in users) to read from the `categories` table
- The `anon` role is for anonymous/public access (if your app doesn't require authentication)
- Choose whichever matches your app's auth model

## Verify It Worked
Go to **Authentication > Policies** in Supabase and check that:
1. `categories` table now has RLS enabled
2. A SELECT policy exists for the role you granted (authenticated or anon)

Your app should now load categories without errors! ✅
