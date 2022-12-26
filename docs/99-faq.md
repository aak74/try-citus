# FAQ


## Есть какие-то фичи, которые не поддерживаются Citus?
[Документация](https://docs.citusdata.com/en/v11.1/faq/faq.html?highlight=hash#are-there-any-postgresql-features-not-supported-by-citus)

- Correlated subqueries
- Recursive CTEs
- Table sample
- SELECT … FOR UPDATE
- Grouping sets

Как обойти эти ограничения указано в [Документации](https://docs.citusdata.com/en/v11.1/develop/reference_workarounds.html).

Например: `SELECT … FOR UPDATE work in single-shard queries only`.
