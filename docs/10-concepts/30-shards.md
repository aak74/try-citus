# Shards
Каждая распределенная таблица разделена на определенное количество шардов.
Обычно стоит выбирать от 32 до 128 шардов.
Для каждого шарда будет открыт коннект к БД, поэтому не стоит увлекаться большими цифрами.
[Как выбрать количество шардов](https://docs.citusdata.com/en/v11.1/admin_guide/cluster_management.html#prod-shard-count)

На каждую ноду может быть распределено несколько шардов.
А могут быть все на одной ноде.

Посмотреть на шарды:

```sql
-- Без распределения по нодам 
SELECT * FROM pg_dist_shard;

-- С распределением по нодам 
SELECT
    shardid,
    node.nodename,
    node.nodeport
FROM pg_dist_placement placement
JOIN pg_dist_node node ON placement.groupid = node.groupid
  AND node.noderole = 'primary'::noderole;

SELECT * FROM citus_shards;
```

## Создание распределенной таблицы
```sql
SELECT create_distributed_table('ads', 'company_id');
```

Количество шардов можно указать при создании распределенной таблицы.
Нужно помнить про локальность данных.
