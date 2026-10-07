import http from "node:http";
import { getMessage } from "./message.js";

const host = process.env.HOST ?? "0.0.0.0";
const port = Number(process.env.PORT ?? 3000);
const responseMode = "REST";

const server = http.createServer((request, response) => {
  const url = new URL(
    request.url ?? "/",
    `http://${request.headers.host ?? "localhost"}`,
  );

  if (url.pathname === "/hello") {
    response.writeHead(200, { "content-type": "text/plain; charset=utf-8" });
    response.end(getMessage(responseMode));
    return;
  }

  response.writeHead(404, { "content-type": "text/plain; charset=utf-8" });
  response.end("Not Found");
});

server.listen(port, host, () => {
  console.log(`Node extension proof listening on http://${host}:${port}`);
});
