Stuff about SQL and relational DBMS such as postgres.

# Postgres

To connect to a PostgreSQL (pg) database, you can use psql, the CLI of pg. You specify the user with the `-U` flag,
followed by the username with which you want to login:

```shell
psql -U <userName>
```

Once connected, you can do the following actions:

* `\l` lists all existing databases.
* `\c <dbName>` connects to the specified db.
* `\d+` returns all tables in currently connected db.
* `\d <tableName>` returns a detailed description of the table and its columns.

## PG IAM

The following actions help you get an understanding of current IAM settings in the pg instance.

The query below obtains all the grants assigned to roles (the `where` conditions ensures we only fetch grants of a
specific user). This takes the grants for the db that you are connected to, not the entire pg instance.

```sql
select * from information_schema.role_table_grants where grantee='YOUR_USER';
```

Schema permissions:

```sql
select
  r.usename as grantor, e.usename as grantee, nspname, privilege_type, is_grantable
from pg_namespace
join lateral (
  SELECT
    *
  from
    aclexplode(nspacl) as x
) a on true
join pg_user e on a.grantee = e.usesysid
join pg_user r on a.grantor = r.usesysid
 where e.usename = 'YOUR_USER';
```

Check activity in a pg instance:

```sql
SELECT * FROM pg_stat_activity
```
