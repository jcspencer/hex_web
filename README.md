# HexWeb

[![Build Status](https://travis-ci.org/hexpm/hex_web.svg?branch=master "Build Status")](http://travis-ci.org/hexpm/hex_web)

## Contributing

To contribute to HexWeb you need to properly set up your development environment.

Also see the client repository: [hex](https://github.com/hexpm/hex). The client uses `hex_web` for integration tests, so `hex_web` needs to support all versions the client supports. Travis tests ensures that tests are run on all supported versions.

### PostgreSQL Modules

HexWeb requires the PostgreSQL modules [pg_trgm](http://www.postgresql.org/docs/9.3/static/pgtrgm.html) and [pgcrypto](http://www.postgresql.org/docs/9.3/static/pgcrypto.html) to be available.

This is located in the "postgresql-contrib" package, however the package name can vary depending on your operating system. If the module is not installed the ecto migrations will fail.

### Database

HexWeb connects to a localhost postgresql database `hex_dev` using the username `postgresql` with the password `postgresql`. Create this database/user if not already done:

```sql
CREATE USER postgres;
ALTER USER postgres PASSWORD 'postgres';
CREATE DATABASE hex_dev;
GRANT ALL PRIVILEGES ON DATABASE hex_dev TO postgres;
ALTER USER postgres WITH SUPERUSER;
```

Now you are fine to run the ecto migrations:

```shell
mix ecto.migrate HexWeb.Repo
```

### Sample Data

Using the following command you can seed your local HexWeb instance with some sample data:

```shell
mix run scripts/sample_data.exs
```

### Running HexWeb

Once the database is set up you can start HexWeb:

```shell
# with console
iex -S mix run

# without console
mix run --no-halt
```

HexWeb will be available at [http://localhost:4000/](http://localhost:4000/).
