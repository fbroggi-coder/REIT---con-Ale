-- Precio manual del subyacente para el panel de opciones.
-- Correr UNA vez en Supabase → SQL Editor (después de opciones.sql).
alter table public.opciones add column if not exists precio_manual    numeric;      -- USD cable; si está cargado, pisa al automático
alter table public.opciones add column if not exists precio_manual_at timestamptz;  -- cuándo se cargó
