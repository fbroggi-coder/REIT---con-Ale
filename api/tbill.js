// Rendimiento del T-Bill a 1 año (FRED, serie DGS1: 1-Year Treasury, constant maturity, % anual).
// GET /api/tbill?desde=YYYY-MM-DD  →  [{ fecha, tasa }]
// Corre en Vercel (el navegador no puede leer FRED directo por CORS).
export default async function handler(req, res) {
  try {
    const desde = /^\d{4}-\d{2}-\d{2}$/.test(req.query?.desde || '') ? req.query.desde : '2024-01-01';
    const url = `https://fred.stlouisfed.org/graph/fredgraph.csv?id=DGS1&cosd=${desde}`;
    const txt = await fetch(url, { headers: { 'User-Agent': 'Mozilla/5.0 (iEB FCIs)' } }).then(r => {
      if (!r.ok) throw new Error('FRED ' + r.status);
      return r.text();
    });
    const out = [];
    for (const line of txt.trim().split(/\r?\n/).slice(1)) {      // 1ra línea: encabezado
      const [fecha, v] = line.split(',');
      const tasa = parseFloat(v);
      if (/^\d{4}-\d{2}-\d{2}$/.test(fecha) && isFinite(tasa)) out.push({ fecha, tasa });  // "." = feriado
    }
    res.setHeader('Cache-Control', 's-maxage=21600, stale-while-revalidate=86400');
    res.status(200).json(out);
  } catch (err) {
    res.status(502).json({ error: err.message });
  }
}
