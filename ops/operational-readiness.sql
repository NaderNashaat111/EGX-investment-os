-- EGX Investment OS operational readiness audit
-- Read-only. Safe for production diagnostics.

-- 1) Core referential/idempotency/safety invariants.
select
  (select count(*) from public.recommendations r left join public.portfolios p on p.id=r.portfolio_id where p.id is null) as recommendation_orphan_portfolio,
  (select count(*) from public.recommendations r left join public.instruments i on i.id=r.instrument_id where i.id is null) as recommendation_orphan_instrument,
  (select count(*) from public.user_decisions d left join public.recommendations r on r.id=d.recommendation_id where r.id is null) as decision_orphan_recommendation,
  (select count(*) from public.ai_thesis_attempts a left join public.ai_thesis_requests q on q.id=a.request_id where q.id is null) as attempt_orphan_request,
  (select count(*) from public.ai_thesis_dispatches d left join public.ai_thesis_requests q on q.id=d.request_id where q.id is null) as dispatch_orphan_request,
  (select count(*) from (select request_id from public.ai_thesis_dispatches group by request_id having count(*)>1) x) as duplicate_dispatch_request,
  (select count(*) from (select request_id,attempt_no from public.ai_thesis_attempts group by request_id,attempt_no having count(*)>1) x) as duplicate_attempt_number,
  (select count(*) from public.recommendations where real_money_execution) as unsafe_real_money_recommendations,
  (select count(*) from public.portfolio_recommendation_generation_runs where real_money_execution) as unsafe_real_money_generation_runs;

-- 2) RLS coverage. Expected: zero rows.
select c.relname as table_name
from pg_class c
join pg_namespace n on n.oid=c.relnamespace
where n.nspname='public' and c.relkind='r' and not c.relrowsecurity
order by c.relname;

-- 3) Direct client mutation surface. Keep intentionally narrow.
select table_name,grantee,privilege_type
from information_schema.role_table_grants
where table_schema='public'
  and grantee in ('anon','authenticated')
  and privilege_type in ('INSERT','UPDATE','DELETE','TRUNCATE')
order by table_name,grantee,privilege_type;

-- Expected authenticated mutations:
--   portfolios UPDATE (owner metadata only, RLS guarded)
--   portfolio_transactions INSERT (owner ledger append, RLS guarded)
-- No authenticated TRUNCATE privilege is acceptable.

-- 4) Latest settled operations snapshot.
select snapshot_date,observed_at,ops_pass,self_test_pass,real_money_execution,health
from public.system_ops_snapshots
order by observed_at desc
limit 1;

-- 5) Known evidence gaps. OPEN rows are investigated individually; they are not
-- automatically global blockers unless the operational contract says so.
select gap_key,gap_type,state,first_known_at,official_published_at,source_locator,attempted_transports,resolution
from public.evidence_source_gaps
where state='OPEN'
order by first_known_at;
