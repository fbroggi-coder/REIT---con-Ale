-- ═══════════════════════════════════════════════════════════════════
-- Panel de opciones (puts vendidos y covered calls) por fondo
-- Correr UNA vez en Supabase → SQL Editor. Después se administra desde la web.
-- ═══════════════════════════════════════════════════════════════════

create table if not exists public.opciones (
  id               bigserial primary key,
  fund_id          text    not null,
  tipo             text    not null check (tipo in ('PUT','CALL')),   -- PUT vendido | CALL vendido (covered call)
  papel            text    not null,          -- subyacente (ticker USA)
  live_symbol      text,                      -- solo si el ticker de precio es distinto del papel
  cantidad         numeric not null,          -- cantidad de acciones (contratos × 100)
  strike           numeric not null,          -- base lanzada
  prima            numeric not null,          -- prima cobrada por acción
  costo_accion     numeric,                   -- solo CALL: precio de compra de la acción
  fecha_operacion  date,                      -- para calcular TNA / TEA
  vencimiento      date    not null,
  estado           text    not null default 'ABIERTA' check (estado in ('ABIERTA','CERRADA')),
  notas            text,
  precio_manual    numeric,                   -- si está cargado, pisa al precio automático
  precio_manual_at timestamptz,
  created_at       timestamptz default now()
);

-- Mismo esquema de acceso que el resto de las tablas de la web (clave anon).
alter table public.opciones enable row level security;
drop policy if exists "opciones lectura"  on public.opciones;
drop policy if exists "opciones alta"     on public.opciones;
drop policy if exists "opciones edicion"  on public.opciones;
drop policy if exists "opciones baja"     on public.opciones;
create policy "opciones lectura" on public.opciones for select using (true);
create policy "opciones alta"    on public.opciones for insert with check (true);
create policy "opciones edicion" on public.opciones for update using (true) with check (true);
create policy "opciones baja"    on public.opciones for delete using (true);

-- ── Carga inicial: Hoja3 de "CC-Puts Ciclo Nova.xlsx" ──────────────
-- Fecha de operación vacía (no estaba en el cuadro) → completar desde la web para ver TNA/TEA.
-- Vencimiento 21/08/2026 tal cual el Excel → revisar: ya pasó.
insert into public.opciones (fund_id, tipo, papel, cantidad, strike, prima, costo_accion, vencimiento) values
  ('CICLO_NOVA','PUT', 'SDS',   9300,  55,  0.71, null,  '2026-08-21'),
  ('CICLO_NOVA','PUT', 'NKE',  12800,  40,  0.63, null,  '2026-08-21'),
  ('CICLO_NOVA','CALL','NFLX',  3600,  70,  2.06, 68.93, '2026-08-21'),
  ('CICLO_NOVA','CALL','APLD', 13300,  35,  1.60, 35.03, '2026-08-21'),
  ('CICLO_NOVA','CALL','AEHR',  3900,  85,  9.20, 83.00, '2026-08-21'),
  ('CICLO_NOVA','PUT', 'GLD',   4400, 340,  4.85, null,  '2026-08-21'),
  ('CICLO_NOVA','PUT', 'SPCX',  5000, 110,  8.50, null,  '2026-08-21'),
  ('CICLO_NOVA','PUT', 'SPCX',  2500,  90,  4.10, null,  '2026-08-21'),
  ('CICLO_NOVA','PUT', 'SPCX',  5000, 100,  7.50, null,  '2026-08-21');
