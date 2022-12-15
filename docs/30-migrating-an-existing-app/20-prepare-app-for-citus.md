# Подготовка приложения для работы с Citus
[Подробно](https://docs.citusdata.com/en/v11.1/develop/migration_mt_query.html)


## Добавление ключа распределения к индексам
Citus может обеспечить уникальность только, если уникальный индекс будет включать в себя ключ распределения.  
Данные распределены по разным нодам и каждая нода может обеспечить уникальность только своих данных.

```sql
BEGIN;

-- drop simple primary keys (cascades to foreign keys)
ALTER TABLE products   DROP CONSTRAINT products_pkey CASCADE;
ALTER TABLE orders     DROP CONSTRAINT orders_pkey CASCADE;
ALTER TABLE line_items DROP CONSTRAINT line_items_pkey CASCADE;

-- recreate primary keys to include would-be distribution column
ALTER TABLE products   ADD PRIMARY KEY (store_id, product_id);
ALTER TABLE orders     ADD PRIMARY KEY (store_id, order_id);
ALTER TABLE line_items ADD PRIMARY KEY (store_id, line_item_id);

-- recreate foreign keys to include would-be distribution column
ALTER TABLE line_items ADD CONSTRAINT line_items_store_fkey FOREIGN KEY (store_id) REFERENCES stores (store_id);
ALTER TABLE line_items ADD CONSTRAINT line_items_product_fkey FOREIGN KEY (store_id, product_id) REFERENCES products (store_id, product_id);
ALTER TABLE line_items ADD CONSTRAINT line_items_order_fkey FOREIGN KEY (store_id, order_id) REFERENCES orders (store_id, order_id);

COMMIT;
```

## Добавление ключа распределения к SQL запросам
Ключ распределения нужно добавлять к SQL запросам и в тех случаях, когда логически это может не являться необходимым.

```sql
-- before
SELECT *
FROM orders
WHERE order_id = 123;

-- after
SELECT *
FROM orders
WHERE order_id = 123
  AND store_id = 42; -- <== added
```

Запросы возвращают одинаковые результаты, но второй запрос выполнится только на одной ноде.
Первый запрос будет выполнен и на остальных нодах.

Для insert добавление `ключа распределения` является критическим.
Только так запись попадет на нужную ноду.

Для запросов с JOIN нужно добавлять фильтр по ключу для локализации выборки на одной ноде.
```sql
-- One way is to include store_id in the join and also
-- filter by it in one of the queries
SELECT sum(l.quantity)
FROM line_items l
INNER JOIN products p ON l.product_id = p.product_id AND l.store_id = p.store_id
WHERE p.name='Awesome Wool Pants'
  AND l.store_id='8c69aa0d-3f13-4440-86ca-443566c1fc75';

-- Equivalently you omit store_id from the join condition
-- but filter both tables by it. This may be useful if
-- building the query in an ORM
SELECT sum(l.quantity)
FROM line_items l
INNER JOIN products p ON l.product_id = p.product_id
WHERE p.name='Awesome Wool Pants'
  AND l.store_id='8c69aa0d-3f13-4440-86ca-443566c1fc75'
  AND p.store_id='8c69aa0d-3f13-4440-86ca-443566c1fc75';
```
