do
$do$
begin
  truncate jobs;

  for chunk_idx in 1..1000 loop
    insert into jobs (chunk_idx) values (chunk_idx);
  end loop;
end
$do$;
