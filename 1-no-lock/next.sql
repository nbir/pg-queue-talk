begin;

update jobs
set is_complete = true
where chunk_idx = (
  select chunk_idx
  from jobs
  where not is_complete
  order by chunk_idx
  limit 1
)
returning chunk_idx;

commit;
