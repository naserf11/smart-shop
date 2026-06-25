# Supabase Database Setup Guide

## Required Tables and Columns

### 1. Categories Table
Create a table named `categories` with the following columns:

| Column | Type | Properties |
|--------|------|-----------|
| id | text | Primary Key |
| name | text | NOT NULL |
| image | text | NOT NULL |
| created_at | timestamp | DEFAULT NOW() |

**Example SQL:**
```sql
CREATE TABLE categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  image TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### 2. Products Table
Create a table named `products` with the following columns:

| Column | Type | Properties |
|--------|------|-----------|
| id | text | Primary Key |
| name | text | NOT NULL |
| description | text | |
| category_id | text | Foreign Key (categories.id) |
| image | text | NOT NULL |
| price | numeric | NOT NULL |
| old_price | numeric | |
| stock | bigint | |
| rating | numeric | |
| is_discounted | boolean | DEFAULT false |
| created_at | timestamp | DEFAULT NOW() |

**Example SQL:**
```sql
CREATE TABLE products (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  category_id TEXT NOT NULL,
  image TEXT NOT NULL,
  price NUMERIC NOT NULL,
  old_price NUMERIC,
  stock BIGINT,
  rating NUMERIC,
  is_discounted BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW(),
  FOREIGN KEY (category_id) REFERENCES categories(id)
);
```

## Migration Steps in Supabase Console

1. Go to **SQL Editor** in your Supabase dashboard
2. Create the `categories` table first
3. Create the `products` table with the foreign key
4. Insert sample data into both tables
5. **IMPORTANT: Disable RLS or create permissive policies** (see Row Level Security section below)

## Row Level Security (RLS) Configuration

**CRITICAL:** If you enabled RLS on the tables, your app cannot read data without policies.

### Option A: Disable RLS (Easiest for Development)
```sql
-- Disable RLS on both tables
ALTER TABLE categories DISABLE ROW LEVEL SECURITY;
ALTER TABLE products DISABLE ROW LEVEL SECURITY;
```

### Option B: Create Permissive Read Policies (Recommended for Production)
```sql
-- Enable RLS
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- Allow all users to SELECT from categories
CREATE POLICY "Allow public select on categories"
ON categories
FOR SELECT
USING (true);

-- Allow all users to SELECT from products
CREATE POLICY "Allow public select on products"
ON products
FOR SELECT
USING (true);
```

**To check current RLS status in Supabase:**
- Go to **Authentication > Policies** tab
- Select each table and check if RLS is enabled
- If RLS is ON but no policies exist, that's why you get permission denied errors

## Sample Data to Insert

```sql
-- Insert categories
INSERT INTO categories (id, name, image) VALUES
('1', 'Fruits & Vegetables', 'assets/images/fruits_vegetables.png'),
('2', 'Breakfast', 'assets/images/egg.png'),
('3', 'Dairy Products', 'assets/images/milk.png'),
('4', 'Seafood', 'assets/images/fish.png');

-- Insert products
INSERT INTO products (id, name, description, category_id, image, price, old_price, stock, rating, is_discounted) VALUES
('1', 'Arla DANO Full Cream Milk Powder', 'Premium full cream milk powder.', '3', 'assets/images/dano.png', 182, 200, 100, 4.7, true),
('2', 'Nestle Nido Milk Powder', 'Nestle milk powder instant.', '3', 'assets/images/nido.png', 270, 342, 85, 4.8, true),
('3', 'Fresh Tomatoes', 'Fresh and ripe tomatoes.', '1', 'assets/images/tomatoes.png', 50, 60, 200, 4.5, true),
('4', 'Organic Carrots', 'Organic carrots from the farm.', '1', 'assets/images/carrots.png', 80, 100, 150, 4.6, true),
('5', 'Fresh Salmon', 'Premium fresh salmon.', '4', 'assets/images/salmon.png', 1500, 1800, 45, 4.9, true);
```

## What Changed in Your App

### Created Files:
- `/lib/services/category_service.dart` - Service to fetch categories from Supabase

### Updated Files:
1. **`/lib/models/product.dart`** - Added JSON serialization/deserialization
2. **`/lib/models/category.dart`** - Added JSON serialization/deserialization
3. **`/lib/services/product_service.dart`** - Updated to fetch from Supabase with methods:
   - `getProducts()` - Get all products
   - `getOffers()` - Get discounted products
   - `getBestSellers()` - Get top-rated products
   - `getProductsByCategory()` - Get products by category
   - `searchProducts()` - Search products by name
4. **`/lib/screens/home/home_screen.dart`** - Updated to use Supabase services with:
   - FutureBuilder for loading states
   - Error handling
   - Proper fallback UI

## Features Implemented

✅ Fetch categories from Supabase  
✅ Fetch products from Supabase  
✅ Filter offers (discounted products)  
✅ Get best sellers (sorted by rating)  
✅ Search products  
✅ Filter by category  
✅ Loading indicators  
✅ Error handling  
✅ Fallback image handling  

## Next Steps

1. Set up the Supabase tables as described above
2. Insert your product and category data into Supabase
3. Test the app to verify data is loading correctly
4. Update other screens that use `DummyData` similarly
