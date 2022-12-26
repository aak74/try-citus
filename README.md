# Проба Citus

Выборочный [перевод](docs/README.md) официальной [документации](https://docs.citusdata.com/en/v11.1/).

## Рекомендации по применению
Citus хорошо использовать на больших БД, у которых много данных, но ограниченное число таблиц.
Косвенно об этом говорит [документация](https://docs.citusdata.com/en/v11.1/develop/app_type.htm).

Для больших БД с большим числом таблиц внедрение может быть проблематичным.
1. Часть функций не [поддерживается](https://docs.citusdata.com/en/v11.1/faq/faq.html?are-there-any-postgresql-features-not-supported-by-citus).  `SELECT … FOR UPDATE`
2. [Подготовка приложения](https://docs.citusdata.com/en/v11.1/develop/migration.html) к использованию Citus не бесплатна.
3. Подготовка БД к миграции может быть непростой задачей. 
   - [Подготовка к миграции](https://docs.citusdata.com/en/v11.1/develop/migration_mt_schema.htm) 
   - [Миграция продуктива](https://docs.citusdata.com/en/v11.1/develop/migration_data_big.html)
4. Запросы в Citus могут стать медленнее.
5. Обслуживание Citus сложнее чем обслуживание одно-нодового PostgreSQL.

### Если БД большая, а таблиц много
Если решение о внедрении Citus принято, то стоит разделить БД на две части. 
1. Первая БД содержит распределяемые таблицы и таблицы справочники, которые участвуют в совместных запросах.
2. Вторая БД содержит остальные таблицы. Чаще всего это таблицы для вспомогательных функций приложения (рассылка сообщений, данные для мобильного приложения и т.д.).

Ожидается, что в первой БД останется намного меньше таблиц, чем было первоначально.
И такую БД будет проще подготовить для использования.

## Links
- [Home](https://www.citusdata.com/)
- [Github](https://github.com/citusdata/citus)
- [Concepts](https://docs.citusdata.com/en/v11.1/get_started/concepts.html)

- [Rebalance Shards without Downtime](https://docs.citusdata.com/en/v11.1/admin_guide/cluster_management.html#rebalance-shards-without-downtime)
- [Dealing With Node Failures](https://docs.citusdata.com/en/v11.1/admin_guide/cluster_management.html#dealing-with-node-failures)
