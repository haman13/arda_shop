-- بروزرسانی ساختار جدول orders برای جداسازی وضعیت سفارش و پرداخت

-- **نکته:** ستون 'payment_status' قبلاً وجود دارد، پس فقط داده‌ها را بروزرسانی می‌کنیم.

-- 1. بروزرسانی داده‌های موجود بر اساس وضعیت فعلی
UPDATE orders SET payment_status = 'paid_online' WHERE status = 'paid';
UPDATE orders SET payment_status = 'cash_on_delivery' WHERE status = 'cash_on_delivery';

-- 2. بروزرسانی وضعیت سفارش‌های موجود
UPDATE orders SET status = 'pending' WHERE status IN ('paid', 'cash_on_delivery');

-- 3. اضافه کردن ایندکس برای بهبود عملکرد (اگر قبلاً اضافه نشده باشد)
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);

-- 4. بروزرسانی محدودیت‌های جدول orders برای پشتیبانی از payment_verified
-- ابتدا محدودیت قدیمی را حذف می‌کنیم (اگر وجود داشته باشد)
DO $$ 
BEGIN
    -- حذف محدودیت قدیمی payment_status اگر وجود داشته باشد
    IF EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'orders_payment_status_check' 
        AND table_name = 'orders'
    ) THEN
        ALTER TABLE orders DROP CONSTRAINT orders_payment_status_check;
    END IF;
    
    -- حذف محدودیت قدیمی status اگر وجود داشته باشد
    IF EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'orders_status_check' 
        AND table_name = 'orders'
    ) THEN
        ALTER TABLE orders DROP CONSTRAINT orders_status_check;
    END IF;
END $$;

-- 5. اضافه کردن محدودیت‌های جدید برای status
ALTER TABLE orders ADD CONSTRAINT orders_status_check 
CHECK (status IN ('pending', 'preparing', 'shipped', 'delivered', 'cancelled'));

-- 6. اضافه کردن محدودیت‌های جدید برای payment_status
ALTER TABLE orders ADD CONSTRAINT orders_payment_status_check 
CHECK (payment_status IN ('unpaid', 'paid_online', 'payment_verified', 'paid_card_to_card', 'cash_on_delivery', 'refunded'));

-- 7. نمایش تعداد سفارش‌ها بر اساس وضعیت جدید (برای بررسی)
SELECT 
    status as order_status,
    payment_status,
    COUNT(*) as count
FROM orders 
GROUP BY status, payment_status
ORDER BY status, payment_status; 