export interface Article {
  title: string;
  description: string;
  link: string;
  pubDate: string;
  source_id: string;
  category?: string[];
}

export interface NewsDataRawResponse {
  status: string;
  totalResults: number;
  results: Article[];
}

export interface NewsResponse {
  status: string;
  total: number;
  articles: Article[];
}

export async function getNews(apiKey: string): Promise<NewsResponse> {
  // Filtramos por Pasto y palabras clave de inseguridad
  const keywords = "Pasto AND (seguridad OR crimen OR robo OR emergencia OR policía OR accidente)";

  const url =
    `https://newsdata.io/api/1/news?` +
    `apikey=${apiKey}` +
    `&country=co` +
    `&language=es` +
    `&q=${encodeURIComponent(keywords)}`;

  const res = await fetch(url);

  if (!res.ok) {
    throw new Error(`Error obteniendo noticias: ${res.status} ${res.statusText}`);
  }

  const data = (await res.json()) as NewsDataRawResponse;

  // Filtrado extra: eliminamos política, deportes y farándula
  const banned = ["politica", "elecciones", "fútbol", "deporte", "farándula"];

  const filtered = (data.results || []).filter(article => {
    const text = `${article.title} ${article.description}`.toLowerCase();
    const allowedKeywords = ["pasto", "seguridad", "crimen", "robo", "emergencia", "policía", "accidente"];
    return allowedKeywords.some(k => text.includes(k)) && !banned.some(b => text.includes(b));
  });

  return {
    status: "success",
    total: filtered.length,
    articles: filtered,
  };
}
