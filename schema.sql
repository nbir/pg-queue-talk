drop table if exists jobs;
create table jobs (
  chunk_idx integer primary key,
  is_complete boolean default false
);
