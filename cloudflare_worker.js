// Cloudflare Workers反代脚本 - 代理api.kurobbs.com
addEventListener('fetch', event => {
  event.respondWith(handleRequest(event.request))
})

async function handleRequest(request) {
  // 目标API地址
  const targetHost = 'api.kurobbs.com'
  const targetUrl = `https://${targetHost}`
  
  // 解析请求URL
  const url = new URL(request.url)
  
  // 构建目标请求URL
  const proxyUrl = new URL(url.pathname + url.search, targetUrl)
  
  // 复制原始请求的headers
  const headers = new Headers(request.headers)
  
  // 设置正确的Host头
  headers.set('Host', targetHost)
  
  // 设置User-Agent（如果需要的话）
  if (!headers.has('User-Agent')) {
    headers.set('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36')
  }
  
  // 添加必要的headers来模拟真实请求
  headers.set('Accept', 'application/json, text/plain, */*')
  headers.set('Accept-Language', 'zh-CN,zh;q=0.9,en;q=0.8')
  headers.set('Accept-Encoding', 'gzip, deflate, br')
  
  // 删除可能导致问题的headers
  headers.delete('cf-connecting-ip')
  headers.delete('cf-ipcountry')
  headers.delete('cf-ray')
  headers.delete('cf-visitor')
  
  try {
    // 创建新的请求
    const modifiedRequest = new Request(proxyUrl.toString(), {
      method: request.method,
      headers: headers,
      body: request.method !== 'GET' && request.method !== 'HEAD' ? await request.arrayBuffer() : null,
    })
    
    // 发送请求到目标服务器
    const response = await fetch(modifiedRequest)
    
    // 创建响应副本
    const modifiedResponse = new Response(response.body, {
      status: response.status,
      statusText: response.statusText,
      headers: response.headers
    })
    
    // 设置CORS headers（如果需要跨域访问）
    modifiedResponse.headers.set('Access-Control-Allow-Origin', '*')
    modifiedResponse.headers.set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
    modifiedResponse.headers.set('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With')
    
    return modifiedResponse
    
  } catch (error) {
    // 错误处理
    return new Response(JSON.stringify({
      error: '代理请求失败',
      message: error.message,
      timestamp: new Date().toISOString()
    }), {
      status: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      }
    })
  }
}

// 处理OPTIONS预检请求
addEventListener('fetch', event => {
  if (event.request.method === 'OPTIONS') {
    event.respondWith(handleOptions(event.request))
  }
})

async function handleOptions(request) {
  return new Response(null, {
    status: 200,
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
      'Access-Control-Max-Age': '86400',
    }
  })
} 