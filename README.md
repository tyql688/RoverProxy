# 🚀 RoverProxy - 多平台反向代理解决方案

> 🎯 支持Termux、Docker、Cloudflare Workers、Node.js的反向代理部署方案

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

#### Nginx Docker 方式
```bash
# 克隆项目
git clone https://github.com/tyql688/RoverProxy.git
cd RoverProxy/proxy-nginx-docker

# 使用默认端口2233启动
docker-compose up -d

# 或指定自定义端口启动
PROXY_PORT=8080 docker-compose up -d
```

#### Node.js Docker 方式
```bash
# 克隆项目
git clone https://github.com/tyql688/RoverProxy.git
cd RoverProxy/proxy-js

# 使用默认端口2233启动
docker-compose up -d

```

### 📦 Node.js 本地部署

#### 环境要求
- Node.js >= 20.0.0
- npm 或 yarn

#### 安装和运行
```bash
# 克隆项目
git clone https://github.com/tyql688/RoverProxy.git
cd RoverProxy/proxy-js

# 安装依赖
npm install

# 运行服务 (默认端口2233)
npm run start
```

### 🤗 Hugging Face Spaces 部署

> Hugging Face Spaces 是免费的机器学习应用托管平台，支持 Docker 部署，非常适合部署代理服务

#### 📋 部署步骤

##### 1. 创建 Hugging Face Space

1. 访问 [Hugging Face Spaces](https://huggingface.co/spaces)
2. 点击 "Create new Space"
3. 配置参数：
   - **Space name**: `rover-proxy`（或您喜欢的名称）
   - **SDK**: 选择 `Docker`
   - **Hardware**: `CPU basic`（免费版本）
   - **Visibility**: `Public` 或 `Private`

##### 2. 准备部署文件

将以下文件复制到您的 Space 仓库中：

```
your-hf-space/
├── server.js              # 从 proxy-js/server.js 复制
├── package.json           # 从 proxy-js/package.json 复制  
├── package-lock.json      # 从 proxy-js/package-lock.json 复制
├── Dockerfile             # 从 proxy-js/Dockerfile 复制
└── .env                   # 需要新建，内容见下方
```

##### 3. 环境配置

**新建** `.env` 文件，内容为：
```env
PROXY_PORT=7860
```

> 💡 **注意**: 7860 是 Hugging Face Spaces 的标准端口，请勿修改

##### 4. 部署和访问

1. 将文件推送到您的 Space 仓库
2. Hugging Face 会自动构建和部署
3. 部署完成后，访问地址为：`https://your-username-rover-proxy.hf.space`


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

## 📁 项目结构

```
RoverProxy/
├── proxy-js/                          # Node.js 代理服务
│   ├── server.js                      # Express 代理服务器
│   ├── package.json                   # Node.js 依赖配置
│   ├── .env                           # 环境变量配置（需要自行新建）
│   ├── Dockerfile                     # Docker 镜像构建文件
│   └── docker-compose.yml             # Docker Compose 配置
├── proxy-nginx-docker/                # Nginx Docker 方案
│   ├── nginx.conf                     # Nginx 配置文件
│   ├── .env                           # 环境变量配置（需要自行新建）
│   ├── Dockerfile                     # Docker 镜像构建文件
│   └── docker-compose.yml             # Docker Compose 配置
├── install_nginx_proxy.sh             # Termux Nginx 一键安装脚本
└── cloudflare_worker.js               # Cloudflare Workers 反代脚本
```