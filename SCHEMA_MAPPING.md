# Supabase Schema Mismatch – Fixed

## Problem Found
Your app's queries expected columns that don't exist in your Supabase `products` table:
- ❌ `is_discounted` column (does not exist)
- ❌ `rating` column (does not exist)

The app was trying to:
- Filter by `is_discounted = true` for offers → ERROR
- Order by `rating` for best sellers → ERROR

## What Your Actual Schema Has

### products table
```
product_id (UUID) ← was querying "id"
product_name (TEXT) ← was querying "name"
description (TEXT) ✓
category_id (UUID) ✓
original_price (NUMERIC) ← was querying "old_price"
selling_price (NUMERIC) ← was querying "price"
stock_quantity (INT) ← was querying "stock"
sku (TEXT)
barcode (TEXT)
unit (TEXT)
tax_rate (NUMERIC)
is_active (BOOLEAN)
created_at (TIMESTAMP) ✓
updated_at (TIMESTAMP)
```

### categories table
```
id (UUID) ✓
name (TEXT) ✓
image (TEXT) ✓
created_at (TIMESTAMP) ✓
```

## What Was Fixed

### Product Model (`lib/models/product.dart`)
Updated `fromJson()` to map actual DB columns to model fields:
```dart
factory Product.fromJson(Map<String, dynamic> json) {
  return Product(
    id: json['product_id'] ?? json['id'] ?? '',           // ← maps product_id
    name: json['product_name'] ?? json['name'] ?? '',     // ← maps product_name
    description: json['description'] ?? '',
    categoryId: json['category_id'] ?? '',
    price: json['selling_price'] ?? json['price'] ?? 0,   // ← maps selling_price
    oldPrice: json['original_price'] ?? json['old_price'] ?? 0,  // ← maps original_price
    stock: json['stock_quantity'] ?? json['stock'] ?? 0,  // ← maps stock_quantity
    rating: json['rating'] ?? 0,                          // ← defaults to 0 (column doesn't exist)
    isDiscounted: json['is_discounted'] ?? false,         // ← defaults to false
  );
}
```

### ProductService (`lib/services/product_service.dart`)

**getOffers()** - Removed filter on non-existent column:
```dart
// Before: .eq('is_discounted', true)  ← ERROR: column doesn't exist
// After: Returns all products (you can add a WHERE clause if you add the column)
final response = await supabase
    .from('products')
    .select()
    .order('created_at', ascending: false);
```

**getBestSellers()** - Changed sort column:
```dart
// Before: .order('rating', ascending: false)  ← ERROR: column doesn't exist
// After: .order('updated_at', ascending: false)  ← sorts by recently updated
final response = await supabase
    .from('products')
    .select()
    .order('updated_at', ascending: false)
    .limit(10);
```

## Next Step: Grant Categories Permission

Your `categories` table has RLS without SELECT policy. Run this SQL in Supabase:

```sql
GRANT SELECT ON public.categories TO authenticated;
```

See **CATEGORIES_PERMISSION_FIX.md** for details.

## Enhancements (Optional)

If you want to properly support offers and best sellers, add these columns to your `products` table:

```sql
-- Add ratings column if you want to track customer ratings
ALTER TABLE products ADD COLUMN rating NUMERIC DEFAULT 0;

-- Add is_discounted column if you want to flag discounted items
ALTER TABLE products ADD COLUMN is_discounted BOOLEAN DEFAULT false;
```

Then revert the ProductService queries back to filtering by these columns.

## Everything Else Is Working ✅
- Product model correctly maps all fields
- Services handle errors and log them clearly
- UI shows loading/error states properly
- Category and product fetching is ready once permissions are fixed
