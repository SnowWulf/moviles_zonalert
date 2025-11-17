class Config {
  /// Cambia a true si quieres probar en local con `wrangler dev`
  static const bool devMode = false;

  /// URL local para pruebas con `wrangler dev` (solo accesible en tu PC)
  static const String devUrl = 'http://127.0.0.1:8787/news';

  /// URL pública de tu Worker desplegado en Cloudflare
  static const String prodUrl = 'https://zonalert-news.zonalert-news.workers.dev/news';

  /// Selecciona la URL según el modo
  static String get newsUrl => devMode ? devUrl : prodUrl;
}
