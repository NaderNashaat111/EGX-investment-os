-- EGX Investment OS — calibration report
-- Read-only queries for the validated shadow cohort.
-- Do not change model/policy thresholds based on immature horizons.

-- 1) Evaluation maturity and completion by horizon.
select
  horizon_days,
  count(*) as scheduled,
  count(*) filter (where evaluated_at is not null) as evaluated,
  count(*) filter (where evaluated_at is null) as pending,
  min(due_at) as first_due_at,
  max(due_at) as last_due_at
from public.shadow_candidate_evaluations
where is_active_generation is true
  and coalesce(superseded,false) is false
group by horizon_days
order by horizon_days;

-- 2) Evaluated outcome distribution by horizon.
select
  horizon_days,
  outcome_state,
  count(*) as observations,
  avg(total_return) as avg_total_return,
  avg(benchmark_return) as avg_benchmark_return,
  avg(excess_return) as avg_excess_return,
  percentile_cont(0.5) within group (order by total_return) as median_total_return,
  percentile_cont(0.5) within group (order by excess_return) as median_excess_return
from public.shadow_candidate_evaluations
where evaluated_at is not null
  and is_active_generation is true
  and coalesce(superseded,false) is false
group by horizon_days, outcome_state
order by horizon_days, outcome_state;

-- 3) Candidate-level calibration detail.
select
  i.ticker,
  c.proposed_action,
  c.candidate_state,
  c.allocation_state,
  c.rank_score,
  e.horizon_days,
  e.entry_session_date,
  e.exit_session_date,
  e.entry_price,
  e.exit_price,
  e.total_return,
  e.benchmark_return,
  e.excess_return,
  e.outcome_state,
  e.evaluated_at
from public.shadow_candidate_evaluations e
join public.shadow_recommendation_candidates c on c.id=e.candidate_id
join public.instruments i on i.id=c.instrument_id
where e.evaluated_at is not null
  and e.is_active_generation is true
  and coalesce(e.superseded,false) is false
order by e.horizon_days, e.excess_return desc nulls last, i.ticker;

-- 4) Recommendation action mix for current-release cohort.
select
  action,
  confidence,
  count(*) as recommendations,
  avg(strength) as avg_strength,
  min(created_at) as first_created_at,
  max(created_at) as last_created_at
from public.recommendations
where real_money_execution is false
  and output_contract_version is not null
group by action, confidence
order by action, confidence;

-- 5) Quality and risk gate summary.
select
  q.quality_state,
  count(*) as theses
from public.thesis_quality_reviews q
group by q.quality_state
order by q.quality_state;

select
  candidate_state,
  allocation_state,
  count(*) as candidates
from public.shadow_recommendation_candidates_current
group by candidate_state, allocation_state
order by candidate_state, allocation_state;

select
  risk_state,
  count(*) as assessments,
  avg(participation_pct) as avg_participation_pct,
  avg(projected_single_stock_pct) as avg_projected_single_stock_pct,
  avg(projected_sector_pct) as avg_projected_sector_pct,
  avg(projected_cash_reserve_pct) as avg_projected_cash_reserve_pct
from public.shadow_pretrade_assessments_current
group by risk_state
order by risk_state;

-- 6) Safety invariant: must remain zero before explicit go-live approval.
select jsonb_build_object(
  'recommendations_real_money_true', (select count(*) from public.recommendations where real_money_execution is true),
  'shadow_candidates_real_money_true', (select count(*) from public.shadow_recommendation_candidates where real_money_execution is true),
  'shadow_pretrade_real_money_true', (select count(*) from public.shadow_pretrade_assessments where real_money_execution is true),
  'shadow_order_intents_real_money_true', (select count(*) from public.shadow_order_intents where real_money_execution is true),
  'shadow_order_fills_real_money_true', (select count(*) from public.shadow_order_fills where real_money_execution is true)
) as safety_invariant;
