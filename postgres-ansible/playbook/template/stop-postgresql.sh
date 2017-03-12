#!/bin/bash
pg_ctl -D $PGDATA stop >> /var/log/postgresql/postgres.log &
