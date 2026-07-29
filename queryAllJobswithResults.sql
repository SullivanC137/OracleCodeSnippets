with chain_jobs as (
    select j.owner                                  as job_owner,
           j.job_name,
           j.job_action                             as chain_action,
           case
               when instr(j.job_action, '.') > 0
               then replace(
                        substr(j.job_action, 1, instr(j.job_action, '.') - 1),
                        '"'
                    )
               else j.owner
           end                                      as chain_owner,
           replace(
               case
                   when instr(j.job_action, '.') > 0
                   then substr(j.job_action, instr(j.job_action, '.') + 1)
                   else j.job_action
               end,
               '"'
           )                                        as chain_name
    from   dba_scheduler_jobs j
    where  j.job_type = 'CHAIN'
),
step_runs as (
    select r.log_id,
           r.owner                                  as job_owner,
           r.job_name,
           r.job_subname                            as step_name,
           r.status,
           r.actual_start_date,
           r.run_duration,
           r.error#,
           r.errors,
           r.additional_info
    from   dba_scheduler_job_run_details r
    where  r.job_subname is not null
    and    r.actual_start_date >= systimestamp - interval '24' hour
)
select r.job_owner,
       r.job_name                                   as chain_job,
       j.chain_owner,
       j.chain_name,
       r.step_name,
       s.program_owner,
       s.program_name,
       r.status,
       r.error#,
       r.errors,
       r.actual_start_date,
       r.run_duration,
       r.additional_info
from   step_runs r
join   chain_jobs j
       on  j.job_owner = r.job_owner
       and j.job_name  = r.job_name
left join dba_scheduler_chain_steps s
       on  s.owner      = j.chain_owner
       and s.chain_name = j.chain_name
       and s.step_name  = r.step_name
order by
       case
           when r.status in ('FAILED', 'BROKEN', 'STOPPED')
             or nvl(r.error#, 0) <> 0
           then 0
           else 1
       end,
       s.program_owner,
       s.program_name,
       r.actual_start_date desc,
       r.job_name,
       r.step_name;
