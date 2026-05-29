-- Fix: per-user daily AI quota never denied requests once the counter
-- saturated at the cap, so a single user could make unlimited (billable)
-- Anthropic calls per day — the server cap is the only real cost defense.
--
-- The original `ai_usage_increment` clamped the stored count at p_cap:
--     set count = case when au.count < p_cap then au.count + 1 else au.count end
-- so once `count` reached the cap it stuck there and `count <= p_cap` stayed
-- true forever (50 <= 50 = true on every subsequent call).
--
-- Always increment instead. Now call N returns `N <= p_cap`: the call that hits
-- the cap is allowed, and the next one is denied (51 <= 50 = false). The daily
-- counter resets per `current_date`, so unbounded growth within a day is fine
-- (and far below integer range).

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
        set count = au.count + 1,
            updated_at = now()
    returning count into v_new_count;

    return v_new_count <= p_cap;
end;
$$;

revoke all on function public.ai_usage_increment(uuid, integer) from public;
grant execute on function public.ai_usage_increment(uuid, integer) to service_role;
