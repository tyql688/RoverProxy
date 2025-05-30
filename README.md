# 🚀 RoverProxy - 多平台反向代理解决方案

> 🎯 支持Termux、Docker、Cloudflare Workers的nginx反向代理部署方案

## 📋 部署方式

### 🔧 Termux Nginx 部署

#### 一键安装 (自动使用默认端口2233)，推荐新手使用
```bash
curl -fsSL https://raw.githubusercontent.com/tyql688/RoverProxy/master/install_nginx_proxy.sh | bash
```

#### 指定端口安装
```bash
curl -fsSL https://raw.githubusercontent.com/tyql688/RoverProxy/master/install_nginx_proxy.sh | bash -s -- -p 8080
```

#### 🌐 异地组网配置

##### ZeroTier (推荐新手)
1. 访问 [ZeroTier官网](https://www.zerotier.com/) 注册账号，[客户端下载](https://download.zerotier.com/RELEASES/)
2. 创建网络并获取Network ID
3. 手机安装ZeroTier客户端加入网络
4. 服务器也安装ZeroTier加入同一网络
5. 使用虚拟IP访问代理服务

##### Tailscale (推荐高级用户)
1. 访问 [Tailscale官网](https://tailscale.com/) 注册账号，[客户端下载](https://tailscale.com/download/)
2. 手机和服务器都安装Tailscale客户端
3. 使用Tailscale分配的IP地址访问

### 🐳 Docker 部署

#### 使用 Docker Compose (推荐)
```bash
# 克隆项目
git clone https://github.com/tyql688/RoverProxy.git
cd RoverProxy

# 使用默认端口2233启动
docker-compose up -d

# 或指定自定义端口启动
PROXY_PORT=8080 docker-compose up -d
```

#### 手动 Docker 部署
```bash
# 克隆项目并构建镜像
git clone https://github.com/tyql688/RoverProxy.git
cd RoverProxy
docker build -t rover-proxy .

# 使用默认端口2233运行
docker run -d --name rover-proxy --restart unless-stopped -p 2233:2233 rover-proxy

# 或指定自定义端口运行
docker run -d --name rover-proxy --restart unless-stopped -p 8080:2233 rover-proxy
```

### ☁️ Cloudflare Workers 部署

#### 📋 手动部署

##### 1. 创建Worker

1. 登录 [Cloudflare Dashboard](https://dash.cloudflare.com)
2. 点击左侧 "Workers & Pages"
3. 点击 "Create application" > "Create Worker"
4. 给Worker命名（例如：`rover-proxy`）

##### 2. 部署代码

1. 复制 `cloudflare_worker.js` 的内容
2. 在Worker编辑器中粘贴代码
3. 点击 "Save and Deploy"

#### 📝 使用方式

部署后，你的Worker域名类似：`https://rover-proxy.your-subdomain.workers.dev`

## 📁 文件说明

- `install_nginx_proxy.sh` - Termux Nginx一键安装脚本
- `nginx.conf` - Nginx配置文件
- `Dockerfile` - Docker镜像构建文件
- `docker-compose.yml` - Docker Compose配置文件
- `cloudflare_worker.js` - Cloudflare Workers反代脚本