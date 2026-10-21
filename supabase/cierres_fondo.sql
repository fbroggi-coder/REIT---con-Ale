-- ═══════════════════════════════════════════════════════════════════
-- Foto de la cartera de cada cierre (una fila por fondo y fecha)
-- La usa la atribución de performance para cualquier período.
-- Correr UNA vez en Supabase → SQL Editor. Se llena sola con cada PDF que se carga
-- (y con "Cargar PDFs anteriores" desde la pantalla de Atribución).
-- ═══════════════════════════════════════════════════════════════════

create table if not exists public.cierres_fondo (
  fund_id      text  not null,
  fecha        date  not null,
  holdings     jsonb not null,   -- [{ticker, cantidad, cierre}] tal cual el PDF (cierre en moneda del fondo)
  ajustes      jsonb,            -- [{label, val}] disponibilidades, provisiones, etc.
  nav          numeric,          -- valor de cuotaparte del PDF
  cuotapartes  numeric,
  created_at   timestamptz default now(),
  primary key (fund_id, fecha)
);

alter table public.cierres_fondo enable row level security;
drop policy if exists "cierres lectura" on public.cierres_fondo;
drop policy if exists "cierres alta"    on public.cierres_fondo;
drop policy if exists "cierres edicion" on public.cierres_fondo;
create policy "cierres lectura" on public.cierres_fondo for select using (true);
create policy "cierres alta"    on public.cierres_fondo for insert with check (true);
create policy "cierres edicion" on public.cierres_fondo for update using (true) with check (true);
