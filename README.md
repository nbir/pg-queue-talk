Implementing a Job Queue in PostgreSQL

## Install

- `brew install postgres`
- `pip install psycopg2` or `pip install psycopg2-binary`

## Usage

- `make db` to create database
- `make schema` to create schema
- `make data` to populate test data

## Explanation

A job row consists of two attributes - `chunk_idx` and `is_complete`. The job queue needs to order jobs by `chunk_idx` while checking that the job is not already completed, and needs to guarantee that each job is only assigned to a single consumer.

All test cases are using a 1000 row test data set.

### 1-no-lock

Run `psql -d jobs -f next.sql` to fetch and complete one job.

Run `psql -d jobs -f delay.sql` and then run `psql -d jobs -f next.sql` on a separate tab. Both queries should return the same `chunk_idx` because the select sub-query does not lock the row.

Run `python consumer.py` to run 2 consumers on separate threads that fetch and complete jobs using the same next query as above. Both consumers should get a large number or duplicate jobs (total consumed jobs != size of test data).

The limitation of this approach is concurrency.
