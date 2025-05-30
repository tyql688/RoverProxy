FROM nginx:alpine

# 复制配置文件
COPY nginx.conf /etc/nginx/nginx.conf

# 暴露端口
EXPOSE 2233

# 设置时区
RUN /bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai' > /etc/timezone

# 设置编码
ENV LANG C.UTF-8