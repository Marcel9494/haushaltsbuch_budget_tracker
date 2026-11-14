-- Schützt users.premium_override vor Änderungen aus der App.
--
-- Vorher konnte jeder eingeloggte Benutzer über die REST-API (mit dem
-- öffentlichen Anon-Key aus der App) premium_override in seiner eigenen
-- Zeile auf true setzen und sich so Premium freischalten, weil die
-- RLS-Policy "userRLS" ALL auf die eigene Zeile erlaubt.
--
-- Ab jetzt gilt für die Rollen anon und authenticated:
--   * INSERT: premium_override wird immer auf false gesetzt.
--   * UPDATE: premium_override behält immer seinen bisherigen Wert.
-- Der SQL-Editor / das Dashboard (postgres) und service_role können den
-- Wert weiterhin setzen.
--
-- Bewusst als Trigger statt REVOKE auf Spaltenebene: Ältere App-Versionen
-- schicken premium_override beim Anlegen des Benutzers noch mit. Mit einem
-- REVOKE würde deren Registrierung fehlschlagen, mit dem Trigger nicht.

create or replace function public.protect_premium_override()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if current_user in ('anon', 'authenticated') then
    if tg_op = 'INSERT' then
      new.premium_override := false;
    else
      new.premium_override := old.premium_override;
    end if;
  end if;

  return new;
end;
$$;

drop trigger if exists protect_premium_override on public.users;

create trigger protect_premium_override
  before insert or update on public.users
  for each row
  execute function public.protect_premium_override();
