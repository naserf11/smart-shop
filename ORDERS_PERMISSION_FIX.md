# Fix Orders & Payment Permissions in Supabase

## Problem
The `orders`, `order_items`, and `customer_addresses` tables have **Row Level Security (RLS) enabled** without the necessary INSERT/SELECT policies for authenticated users. This prevents the app from creating or reading orders.

## Solution: Run This SQL in Supabase

### Step 1: Open Supabase Dashboard
1. Go to https://app.supabase.com
2. Select your project
3. Go to **SQL Editor** on the left sidebar

### Step 2: Run This SQL

**Option A: Simplest (Disable RLS for testing):**
```sql
-- Disable RLS on orders-related tables for testing
ALTER TABLE orders DISABLE ROW LEVEL SECURITY;
ALTER TABLE order_items DISABLE ROW LEVEL SECURITY;
ALTER TABLE customer_addresses DISABLE ROW LEVEL SECURITY;
ALTER TABLE customers DISABLE ROW LEVEL SECURITY;
```

**Option B: Recommended (Create proper policies):**
```sql
-- Enable RLS
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE customer_addresses ENABLE ROW LEVEL SECURITY;

-- Orders: Allow authenticated users to SELECT and INSERT
CREATE POLICY "Allow authenticated select on orders"
ON orders FOR SELECT TO authenticated
USING (true);

CREATE POLICY "Allow authenticated insert on orders"
ON orders FOR INSERT TO authenticated
WITH CHECK (true);

-- Order Items: Allow authenticated users to SELECT and INSERT
CREATE POLICY "Allow authenticated select on order_items"
ON order_items FOR SELECT TO authenticated
USING (true);

CREATE POLICY "Allow authenticated insert on order_items"
ON order_items FOR INSERT TO authenticated
WITH CHECK (true);

-- Customer Addresses: Allow authenticated users to SELECT and INSERT
CREATE POLICY "Allow authenticated select on customer_addresses"
ON customer_addresses FOR SELECT TO authenticated
USING (true);

CREATE POLICY "Allow authenticated insert on customer_addresses"
ON customer_addresses FOR INSERT TO authenticated
WITH CHECK (true);

-- Customers: Allow authenticated users to SELECT, INSERT, and UPDATE
CREATE POLICY "Allow authenticated select on customers"
ON customers FOR SELECT TO authenticated
USING (true);

CREATE POLICY "Allow authenticated insert on customers"
ON customers FOR INSERT TO authenticated
WITH CHECK (true);

CREATE POLICY "Allow authenticated update on customers"
ON customers FOR UPDATE TO authenticated
USING (true);
```

### Step 3: Verify
1. Run the SQL above
2. Test the payment flow in the app
3. After completing a payment, check the `orders` and `order_items` tables in Supabase to see the new rows

## Database Schema Reference

### orders table
```
order_id        (UUID)      - Primary Key, auto-generated
customer_id     (UUID)      - FK → customers.customer_id
order_type      (TEXT)      - e.g. 'self_checkout'
order_status    (TEXT)      - e.g. 'pending', 'confirmed', 'delivered'
total_amount    (NUMERIC)   - Total price
address_id      (UUID)      - FK → customer_addresses.address_id
created_at      (TIMESTAMP) - Auto-generated
updated_at      (TIMESTAMP) - Auto-generated
```

### order_items table
```
order_item_id   (UUID)      - Primary Key, auto-generated
order_id        (UUID)      - FK → orders.order_id
product_id      (UUID)      - FK → products.product_id
quantity        (INT)       - Number of items
line_total      (NUMERIC)   - quantity × price
```

### customer_addresses table
```
address_id      (UUID)      - Primary Key, auto-generated
customer_id     (UUID)      - FK → customers.customer_id
address_line_1  (TEXT)
address_line_2  (TEXT)
city            (TEXT)
state           (TEXT)
postcode        (TEXT)
country         (TEXT)
is_default      (BOOLEAN)
created_at      (TIMESTAMP)
```
