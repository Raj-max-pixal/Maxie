const fs = require("fs");
const http = require("http");
const path = require("path");

const root = path.resolve(__dirname, "..");
const port = Number(process.env.MAXIE_PREVIEW_PORT || 4174);

const types = {
  ".html": "text/html; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".js": "application/javascript; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".webmanifest": "application/manifest+json; charset=utf-8",
  ".png": "image/png",
  ".gif": "image/gif",
  ".ico": "image/x-icon"
};

http.createServer((request, response) => {
  let requestPath = new URL(request.url, `http://${request.headers.host}`).pathname;
  if (requestPath === "/") requestPath = "/index.html";

  const filePath = path.normalize(path.join(root, decodeURIComponent(requestPath)));
  if (!filePath.startsWith(root)) {
    response.writeHead(403);
    response.end("Forbidden");
    return;
  }

  fs.readFile(filePath, (error, data) => {
    if (error) {
      response.writeHead(404);
      response.end("Not found");
      return;
    }

    response.writeHead(200, {
      "Content-Type": types[path.extname(filePath)] || "application/octet-stream"
    });
    response.end(data);
  });
}).listen(port, "127.0.0.1", () => {
  console.log(`MAXie preview server running at http://127.0.0.1:${port}`);
});
