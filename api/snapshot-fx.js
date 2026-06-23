export default async function handler(req, res) {
  const SB_URL = 'https://xyoxonwufbrorwsoyyce.supabase.co';
  const SB_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh5b3hvbnd1ZmJyb3J3c295eWNlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE3MjA4OTUsImV4cCI6MjA5NzI5Njg5NX0.b7uBEOnBMK9VjD_AuRaiNSv1IOh2_gVO72ybk9OL5KM';

  try {
    // Fetch MEP
    const mepArr = await fetch('https://data912.com/live/mep').then(r => r.json()).catch(() => []);
    const mepMap = {};
    (mepArr || []).forEach(o => { if (o && o.ticker) mepMap[o.ticker] = o; });
    const mepRow = mepMap['AL30'] || mepMap['GD30'] || mepMap['AL30D'];
    const mep = mepRow ? (mepRow.mark || mepRow.close) : null;

    // Fetch CCL
    const cclArr = await fetch('https://data912.com/live/ccl').then(r => r.json()).catch(() => []);
    const cclMap = {};
    (cclArr || []).forEach(o => { if (o && o.ticker) cclMap[o.ticker] = o; });
    const cclRow = cclMap['AL30'] || cclMap['GD30'];
    const ccl = cclRow ? (cclRow.mark || cclRow.close) : null;

    // Fecha en horario Argentina (UTC-3)
    const now = new Date();
    const argDate = new Date(now.getTime() - 3 * 60 * 60 * 1000);
    const fecha = argDate.toISOString().slice(0, 10);

    // Upsert en Supabase
    await fetch(`${SB_URL}/rest/v1/fx_history`, {
      method: 'POST',
      headers: {
        'apikey': SB_KEY,
        'Authorization': `Bearer ${SB_KEY}`,
        'Content-Type': 'application/json',
        'Prefer': 'resolution=merge-duplicates'
      },
      body: JSON.stringify({ fecha, mep, ccl })
    });

    res.status(200).json({ ok: true, fecha, mep, ccl });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
}
