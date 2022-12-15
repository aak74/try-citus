# Определение стратегии распределения таблиц (Identify Distribution Strategy)
[Подробно](https://docs.citusdata.com/en/v11.1/develop/migration_mt_schema.html)

## План миграции
- Выберите ключ распределения (distribution key)
- Определите типы таблиц
- Подготовьте исходные таблицы к миграции

## Описание подготовительных шагов

### Выбор ключа распределения
1. [Определите тип вашего приложения](../20-develop/10-determine-app-type.md).
2. [Выберите ключ распределения](../20-develop/20-choosing-distribution-column.md).


### Определение типов таблиц
После определения ключей распределения, определите как будет обрабатываться каждая таблица в вашей БД.  
Какие изменения нужно внести в таблицу, чтобы она могла эффективно использоваться в Citus.

[Шаблон](https://docs.google.com/spreadsheets/d/1jYlc22lHdP91pTrb6s35QfrN9nTE1BkVJnCSZeQ7ZmI/edit) для заполнения.

| Table Name | Table Size | Distribution Key | Citus Type             | Action Needed | Status | Notes |
|------------|------------|------------------|------------------------|---------------|--------|-------|
| companies  | 1Mb        |                  | reference              | no            | ready  |       |
| campaigns  | 10Mb       | id, company_id   | Ready for distribution | no            | ready  |       |
| ads        | 100Mb      | id, company_id   | Ready for distribution | no            | ready  |       |


Таблицы попадают в следующие категории:
- `Ready for distribution`. Готова к распределению. Уже содержит ключ для распределения.
- `Needs backfill`. Нужно заполнение. Таблицы логически распределены по ключу, но физически этого ключа нет в таблице.
  Требуется добавить ключ распределения в эту таблицу.
- `Reference table`. Таблица справочник. Таблицы относительно маленькие. Не содержат ключа распределения.
  Часто объединяются по JOIN и могут быть совместно использованы разными тенантами.
  Копия таблицы будет распределена на каждую ноду.
  Пример: список стран, список городов.
- `Local table`. Локальная таблица. Обычно не объединяются по JOIN с другими таблицами.
  Не содержат ключа распределения. Находится только на координаторе. 
  Пример: список белых IP, список токенов, другие вспомогательные таблицы.

### Подготовка исходных таблиц к миграции
[Подробно](https://docs.citusdata.com/en/v11.1/develop/migration_mt_schema.html#prepare-source-tables-for-migration)

#### Добавление ключа распределения

```sql
-- denormalize line_items by including store_id

ALTER TABLE line_items ADD COLUMN store_id uuid;
```

Убедитесь, что ключ имеет один и тот же тип для всех таблиц.
Нужно иметь в виду, что `bigint` и `int` это разные типы.

#### Заполнение созданной колонки
Пример:
```sql
UPDATE line_items
SET store_id = orders.store_id
FROM line_items
INNER JOIN orders
WHERE line_items.order_id = orders.order_id;
```

В реальной жизни для больших таблиц такой запрос будет выполняться очень долго и даст существенную нагрузку. 

Пример функции для постепенного заполнения колонки:
```sql
-- the function to backfill up to one
-- thousand rows from line_items
CREATE FUNCTION backfill_batch()
RETURNS void LANGUAGE sql AS $$
  WITH batch AS (
    SELECT line_items_id, order_id
    FROM line_items
    WHERE store_id IS NULL
    LIMIT 1000
    FOR UPDATE
    SKIP LOCKED
  )
  UPDATE line_items AS li
  SET store_id = orders.store_id
  FROM batch, orders
  WHERE batch.line_item_id = li.line_item_id
    AND batch.order_id = orders.order_id;
$$;

-- run the function every quarter hour with pg_cron extension
SELECT cron.schedule('*/15 * * * *', 'SELECT backfill_batch()');

-- ^^ note the return value of cron.schedule

-- assuming 42 is the job id returned
-- from cron.schedule
SELECT cron.unschedule(42);
```
