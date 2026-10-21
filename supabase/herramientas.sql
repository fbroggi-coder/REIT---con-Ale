-- ═══════════════════════════════════════════════════════════════════
-- Herramientas: vencimientos, resultado vs costo, renta fija, concentración
-- Correr UNA vez en Supabase → SQL Editor.
-- ═══════════════════════════════════════════════════════════════════

-- 1) Vencimiento y costo de cada tenencia (los lee el PDF de Ciclo Nova)
alter table public.holdings add column if not exists vencimiento date;
alter table public.holdings add column if not exists costo       numeric;   -- costo por unidad, en moneda del fondo

-- 2) Parámetros de renta fija para TIR y duration (uno por fondo y activo)
create table if not exists public.renta_fija_params (
  fund_id        text    not null,
  ticker         text    not null,
  metodo         text    not null default 'cero' check (metodo in ('cero','bullet','flujos','manual')),
  moneda_flujos  text    not null default 'USD'  check (moneda_flujos in ('USD','USD cable','ARS')),
  vencimiento    date,              -- si está vacío se usa el del PDF
  cupon          numeric,           -- % anual (bullet)
  frecuencia     integer,           -- pagos por año (bullet)
  valor_final    numeric,           -- pago final por 1 de nominal (cero / bullet), default 1
  flujos         jsonb,             -- [{fecha:'YYYY-MM-DD', monto}] por 1 de nominal (flujos)
  tir_manual     numeric,           -- % anual (manual)
  md_manual      numeric,           -- duration modificada en años (manual)
  updated_at     timestamptz default now(),
  primary key (fund_id, ticker)
);

-- 3) Límites de concentración
create table if not exists public.limites (
  fund_id   text    not null,
  tipo      text    not null check (tipo in ('general_activo','activo','tipo','moneda','categoria','liquidez_min')),
  clave     text    not null default '',   -- ticker / tipo / moneda / categoría ('' para general y liquidez)
  max_pct   numeric,                       -- % máximo del patrimonio
  min_pct   numeric,                       -- % mínimo (liquidez)
  updated_at timestamptz default now(),
  primary key (fund_id, tipo, clave)
);

-- Mismo esquema de acceso que el resto de las tablas de la web (clave anon)
alter table public.renta_fija_params enable row level security;
alter table public.limites           enable row level security;
drop policy if exists "rf lectura" on public.renta_fija_params;
drop policy if exists "rf escritura" on public.renta_fija_params;
drop policy if exists "rf edicion" on public.renta_fija_params;
drop policy if exists "rf baja" on public.renta_fija_params;
create policy "rf lectura"   on public.renta_fija_params for select using (true);
create policy "rf escritura" on public.renta_fija_params for insert with check (true);
create policy "rf edicion"   on public.renta_fija_params for update using (true) with check (true);
create policy "rf baja"      on public.renta_fija_params for delete using (true);
drop policy if exists "lim lectura" on public.limites;
drop policy if exists "lim escritura" on public.limites;
drop policy if exists "lim edicion" on public.limites;
drop policy if exists "lim baja" on public.limites;
create policy "lim lectura"   on public.limites for select using (true);
create policy "lim escritura" on public.limites for insert with check (true);
create policy "lim edicion"   on public.limites for update using (true) with check (true);
create policy "lim baja"      on public.limites for delete using (true);
