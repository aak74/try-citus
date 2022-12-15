CREATE EXTENSION citus;

SELECT * from citus_add_node('node-name', 5432);
SELECT * from citus_add_node('node-name2', 5432);

SELECT run_command_on_workers('show ssl');

SELECT run_command_on_workers($$
  SELECT version FROM pg_stat_ssl WHERE pid = pg_backend_pid()
$$);

SELECT rebalance_table_shards();
SELECT rebalance_table_shards('ads');

SELECT * FROM master_get_active_worker_nodes();

-- find the node currently holding the new shard
SELECT *
FROM citus_shards;

-- list the available worker nodes that could hold the shard
SELECT * FROM master_get_active_worker_nodes();

-- move the shard to your choice of worker
-- (it will also move any shards created with the CASCADE option)
SELECT citus_move_shard_placement(
    102072,
    'try-citus_worker1_1', 5432,
    'try-citus_worker2_1', 5432
);



CREATE EXTENSION pg_stat_statements;
SELECT pg_reload_conf();
SELECT * FROM citus_stat_statements;


-- limit queries to five minutes
ALTER DATABASE citus
    SET statement_timeout TO 300000;
SELECT run_command_on_workers($cmd$
  ALTER DATABASE citus
    SET statement_timeout TO 300000;
$cmd$);


-- Maintenance table

SELECT logicalrelid AS name,
    pg_size_pretty(citus_table_size(logicalrelid)) AS size
FROM pg_dist_partition;

VACUUM (VERBOSE, ANALYZE) ads;
ANALYZE VERBOSE ads;
