-- =====================================================================
-- Issue #163: Buchungsdatum als reines Kalenderdatum speichern
-- =====================================================================
-- Bisher: booking_date = timestamptz, gespeichert wurde die lokale Mitternacht
--         des Geräts in UTC (z.B. 01.03.2028 in Berlin -> 2028-02-29 23:00:00+00).
--         Dadurch wurden Buchungen in anderen Zeitzonen am falschen Tag angezeigt.
-- Neu:    booking_date = date (z.B. 2028-03-01), unabhängig von der Zeitzone.
--
-- Vorher: Backup der Tabelle bookings erstellen!
-- Bestehende Buchungen werden in der Zeitzone aus users.timezone umgerechnet.
-- =====================================================================

begin;

-- 1. Neue Spalte anlegen
alter table public.bookings add column booking_day date;

-- 2. Bestehende Buchungen in der Zeitzone des Nutzers in ein Datum umrechnen
update public.bookings b
set booking_day = (b.booking_date at time zone coalesce(u.timezone, 'Europe/Berlin'))::date
from public.users u
where u.id = b.user_id;

-- Buchungen ohne passenden Nutzer-Eintrag
update public.bookings
set booking_day = (booking_date at time zone 'Europe/Berlin')::date
where booking_day is null;

-- 3. Alte Spalte ersetzen
--    Hinweis: Falls Views, Indizes oder RLS-Policies booking_date verwenden,
--    müssen diese vorher entfernt und danach neu angelegt werden.
alter table public.bookings drop column booking_date;
alter table public.bookings rename column booking_day to booking_date;
alter table public.bookings alter column booking_date set not null;

create index if not exists bookings_user_id_booking_date_idx on public.bookings (user_id, booking_date);

commit;


-- =====================================================================
-- Angepasste Buchungsfunktion für den Cron-Job
-- =====================================================================
-- Eine Buchung wird ab Mitternacht in der Zeitzone des Nutzers gebucht.
-- "for update ... skip locked" verhindert doppeltes Buchen, falls die Funktion
-- parallel läuft.
-- Den Funktionskopf (Name, returns, security definer usw.) bitte von deiner
-- bestehenden Funktion übernehmen und nur den Body ersetzen.
-- =====================================================================
/*
declare
    booking_record record;
begin

    for booking_record in

        select b.*
        from bookings b
        join users u on u.id = b.user_id
        where
            b.is_booked = false
            and b.booking_date <= (now() at time zone coalesce(u.timezone, 'Europe/Berlin'))::date
        order by b.booking_date
        for update of b skip locked

    loop

        -------------------------
        -- Einnahme
        -------------------------

        if booking_record.booking_type = 'income' then

            update accounts
            set balance = balance + booking_record.amount
            where id = booking_record.debit_account_id;

        -------------------------
        -- Ausgabe
        -------------------------

        elsif booking_record.booking_type = 'expense' then

            update accounts
            set balance = balance - booking_record.amount
            where id = booking_record.debit_account_id;

        -------------------------
        -- Übertrag
        -------------------------

        elsif booking_record.booking_type = 'transfer' then

            update accounts
            set balance = balance - booking_record.amount
            where id = booking_record.debit_account_id;

            update accounts
            set balance = balance + booking_record.amount
            where id = booking_record.target_account_id;

        end if;

        update bookings
        set
            is_booked = true
        where id = booking_record.id;

    end loop;

end;
*/
