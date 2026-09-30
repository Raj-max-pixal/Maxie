const http = require('http');
const fs = require('fs');
const path = require('path');

const root = __dirname;
const port = 51988;

http
  .createServer((request, response) => {
    const requestedPath = decodeURIComponent(request.url.split('?')[0]);
    let filePath = path.join(
      root,
      requestedPath === '/' ? 'preview_dynamic_home.html' : requestedPath,
    );

    if (!filePath.startsWith(root) || !fs.existsSync(filePath)) {
      filePath = path.join(root, 'preview_dynamic_home.html');
    }

    fs.readFile(filePath, (error, content) => {
      if (error) {
        response.writeHead(404);
        response.end('Not found');
        return;
      }

      response.writeHead(200, {
        'Content-Type': 'text/html; charset=utf-8',
        'Cache-Control': 'no-store',
      });
      response.end(content);
    });
  })
  .listen(port, '127.0.0.1', () => {
    console.log(`MAXie dynamic preview running at http://127.0.0.1:${port}`);
  });
