# 使用官方Node.js运行时作为基础镜像
FROM node:20-alpine

# 设置工作目录
WORKDIR /app

# 复制package.json
COPY package.json ./

# 安装依赖
RUN npm install --omit=dev

# 复制应用程序代码
COPY . .

# 创建非root用户
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001

# 更改应用程序文件的所有权
RUN chown -R nodejs:nodejs /app
USER nodejs

# 设置默认端口
ENV PROXY_PORT=2233

# 暴露端口
EXPOSE ${PROXY_PORT}

# 启动应用程序
CMD ["npm", "run", "start"] 