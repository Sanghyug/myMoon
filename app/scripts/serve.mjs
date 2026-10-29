import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
const root=path.resolve(fileURLToPath(new URL('../dist/',import.meta.url)));
const types={'.html':'text/html; charset=utf-8','.js':'text/javascript; charset=utf-8','.css':'text/css; charset=utf-8','.png':'image/png','.jpg':'image/jpeg','.json':'application/json'};
const server=http.createServer((req,res)=>{try{const pathname=decodeURIComponent(new URL(req.url,'http://localhost').pathname);let target=path.resolve(root,'.'+pathname);if(target!==root&&!target.startsWith(root+path.sep)){res.writeHead(403).end();return}if(!path.extname(target))target=path.join(root,'index.html');if(!fs.existsSync(target)){res.writeHead(404).end('Not found');return}res.setHeader('Content-Type',types[path.extname(target)]||'application/octet-stream');res.setHeader('Cache-Control','no-cache');fs.createReadStream(target).pipe(res)}catch{res.writeHead(400).end('Bad request')}});
server.listen(5173,'127.0.0.1',()=>console.log('마이문 미리보기: http://127.0.0.1:5173\n종료하려면 Ctrl+C를 누르세요.'));
server.on('error',e=>{console.error(e.code==='EADDRINUSE'?'이미 미리보기가 실행 중이에요: http://127.0.0.1:5173':e.message);process.exitCode=1});
