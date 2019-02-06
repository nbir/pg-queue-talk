db:
	-psql -d postgres -c 'drop database jobs'
	psql -d postgres -c 'create database jobs'

schema:
	psql -d jobs -f schema.sql

data:
	psql -d jobs -f data.sql
