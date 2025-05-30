const express = require('express');
const https = require('https');

const app = express();
const PORT = process.env.PROXY_PORT || 2233;
const TARGET_HOST = 'api.kurobbs.com';

// 获取原始请求体
app.use((req, res, next) => {
  let body = [];
  req.on('data', chunk => body.push(chunk));
  req.on('end', () => {
    req.rawBody = Buffer.concat(body);
    next();
  });
});

// 处理OPTIONS预检请求
app.options('*', (req, res) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');
  res.header('Access-Control-Max-Age', '86400');
  res.status(200).send();
});

// 代理所有请求
app.all('*', (req, res) => {
  const originalUrl = req.originalUrl || req.url;
  
  // 复制headers并设置目标主机
  const headers = { ...req.headers, host: TARGET_HOST };
  delete headers.connection;
  
  // 发送请求
  const proxyReq = https.request({
    hostname: TARGET_HOST,
    port: 443,
    path: originalUrl,
    method: req.method,
    headers: headers
  }, (proxyRes) => {
    // 设置CORS和复制响应头
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');
    
    Object.keys(proxyRes.headers).forEach(key => {
      res.header(key, proxyRes.headers[key]);
    });
    
    res.status(proxyRes.statusCode);
    proxyRes.pipe(res);
  });
  
  proxyReq.on('error', (err) => {
    console.error(`ERR: ${err.message}`);
    res.status(500).json({ error: '代理失败' });
  });
  
  // 发送请求体
  if (req.method !== 'GET' && req.method !== 'HEAD' && req.rawBody?.length > 0) {
    proxyReq.write(req.rawBody);
  }
  
  proxyReq.end();
});

app.listen(PORT, '0.0.0.0', () => {
  console.log('\n🚀 ===================================');
  console.log('   Kurobbs 反向代理服务器');
  console.log('🚀 ===================================');
  console.log(`📡 监听端口: ${PORT}`);
  console.log(`🎯 代理目标: https://${TARGET_HOST}`);
  console.log(`🌐 访问地址: http://localhost:${PORT}`);
  console.log('🚀 ===================================\n');
}); 