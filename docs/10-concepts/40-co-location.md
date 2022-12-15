# Co-location (локальность данных)
На каждой ноде хранится только часть данных.
Необходимо соблюдать локальность данных, чтобы выборки с JOIN были эффективными.

## Не соблюдение локальности данных
Есть две таблицы:
- order (distribution_column = order_id);
- order_product_item (distribution_column = product_id).

Данные таблицы `order` с order_id = 1 могут храниться на ноде `worker-1`.
А данные таблицы `order_product_item` с order_id = 1 могут храниться на нескольких разных нодах `worker-1`.
Запрос с джойном этих таблиц будет неэффективен.
Потому что возникнет много лишнего трафика по сети и дополнительной работы по объединению данных.

Для эффективной работы для таблицы `order_product_item` нужно выбрать `distribution_column = order_id`.
Тогда JOIN может быть сделан в рамках одной ноды.

[Подробно тут](https://docs.citusdata.com/en/v11.1/sharding/data_modeling.html#colocation).
