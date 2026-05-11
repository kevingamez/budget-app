-- AI insights per-user daily usage counter.
--
-- The Edge Function (`ai-insights`) calls `ai_usage_increment(user_id, cap)`
-- with the service-role key. The RPC is SECURITY DEFINER so it can write to
-- this table without RLS in the way, and atomic via ON CONFLICT so concurrent
-- requests cannot exceed the cap by interleaving.

create table if not exists public.ai_usage (
    user_id uuid not null,
    day date not null,
    count integer not null default 0,
    updated_at timestamptz not null default now(),
    primary key (user_id, day)
);

alter table public.ai_usage enable row level security;

-- No client policy is added. Only the Edge Function (service-role) writes
-- here; users do not read or update their own counters directly.

create or replace function public.ai_usage_increment(
    p_user_id uuid,
    p_cap integer
) returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
    v_new_count integer;
begin
    if p_user_id is null then
        return false;
    end if;
    if p_cap is null or p_cap < 1 then
        return false;
    end if;

    insert into public.ai_usage as au (user_id, day, count, updated_at)
    values (p_user_id, current_date, 1, now())
    on conflict (user_id, day) do update
        set count = case when au.count < p_cap then au.count + 1 else au.count end,
            updated_at = now()
    returning count into v_new_count;

    return v_new_count <= p_cap;
end;
$$;

revoke all on function public.ai_usage_increment(uuid, integer) from public;
grant execute on function public.ai_usage_increment(uuid, integer) to service_role;
