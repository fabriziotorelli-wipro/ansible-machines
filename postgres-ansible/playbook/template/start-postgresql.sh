#!/bin/bash
pg_ctl -D $PGDATA start >> /var/log/postgresql/postgres.log &
