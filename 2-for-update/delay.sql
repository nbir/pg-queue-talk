begin;

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

select pg_sleep(10); -- sleep for 10 seconds

commit;
