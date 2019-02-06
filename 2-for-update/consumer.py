import psycopg2
import threading
# import time

NUM_CONSUMERS = 4

SQL = '''
update jobs
set is_complete = true
where chunk_idx = (
  select chunk_idx
  from jobs
  where not is_complete
  order by chunk_idx
  for update
  limit 1
)
returning chunk_idx;
'''


def consume():
    print('Starting consumer...')

    conn = psycopg2.connect('dbname=jobs')

    jobs_consumed = 0

    while (True):
        cur = conn.cursor()
        cur.execute(SQL)
        result = cur.fetchone()

        if result is None:
            break

        # if result[0] % 100 == 0:
        #     time.sleep(1)

        conn.commit()

        jobs_consumed += 1

    cur.close()
    conn.close()

    print('This thread consumed {} jobs'.format(jobs_consumed))


if __name__ == '__main__':
    for i in range(NUM_CONSUMERS):
        thread = threading.Thread(target=consume)
        thread.start()
