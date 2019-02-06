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

### 2-for-update

Run `psql -d jobs -f next.sql` to fetch and complete one job.

Run `psql -d jobs -f delay.sql` and then run `psql -d jobs -f next.sql` on a separate tab. The two queries should return different `chunk_idx`s because `SELECT... FOR UPDATE` locks the row. Note that the next query without delay waits for the delayed query transaction to commit.

Run `python consumer.py` to run 4 consumers on separate threads that fetch and complete jobs using the same next query as above. The consumers should not get any duplicate jobs (total consumed jobs = size of test data).

If an artificial delay of 1 second was introduced for every 100th job, and 10 consumers were run concurrently, it would take at least 10 seconds to consume the entire queue since each query is executed sequentially.

### 3-skip-locked

Run `psql -d jobs -f next.sql` to fetch and complete one job.

Run `psql -d jobs -f delay.sql` and then run `psql -d jobs -f next.sql` on a separate tab. The two queries should return different `chunk_idx`s. Note that the next query without delay does not wait for the delayed query transaction to commit because `SELECT... FOR UPDATE SKIP LOCK` ignores locked rows.

Run `python consumer.py` to run 10 consumers on separate threads that fetch and complete jobs using the same next query as above. The consumers should not get any duplicate jobs (total consumed jobs = size of test data).

If an artificial delay of 1 second was introduced for every 100th job, and 10 consumers were run concurrently, it would take at least 1 seconds but (generally) less than 10 seconds because queries can run independent of each other.
