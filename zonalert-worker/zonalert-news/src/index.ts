import { getNews } from "./news";

export interface Env {
  NEWSDATA_KEY: string;
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    console.log("DEBUG: env =", env); // <--- temporal
    const url = new URL(request.url);

    if (url.pathname === "/news") {
      try {
        if (!env.NEWSDATA_KEY) {
          return new Response(JSON.stringify({
            status: "error",
            total: 0,
            message: "API Key no configurada"
          }), { headers: { "Content-Type": "application/json" } });
        }

        const data = await getNews(env.NEWSDATA_KEY);
        return new Response(JSON.stringify(data), {
          headers: { "Content-Type": "application/json" }
        });
      } catch (err: any) {
        return new Response(JSON.stringify({
          status: "error",
          message: err.message
        }), {
          status: 500,
          headers: { "Content-Type": "application/json" }
        });
      }
    }

    return new Response(JSON.stringify({ status: "not found" }), {
      status: 404,
      headers: { "Content-Type": "application/json" }
    });
  }
};
