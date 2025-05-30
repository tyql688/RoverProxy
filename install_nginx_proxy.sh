#!/data/data/com.termux/files/usr/bin/bash

# Termux Nginx反向代理一键安装脚本
# 作者: RoverProxy
# 用途: 反向代理api.kurobbs.com

# 默认配置
DEFAULT_PORT=2233
PROXY_PORT=""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查是否为交互式环境
is_interactive() {
    [[ -t 0 && -t 1 ]]
}

# 显示帮助信息
show_help() {
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -p, --port PORT    指定nginx监听端口 (1024-65535)"
    echo "  -h, --help         显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0                 # 交互式安装"
    echo "  $0 -p 8080         # 使用端口8080安装"
    echo ""
    echo "一键安装命令:"
    echo "  curl -fsSL https://raw.githubusercontent.com/tyql688/RoverProxy/master/install_nginx_proxy.sh | bash"
    echo "  curl -fsSL https://raw.githubusercontent.com/tyql688/RoverProxy/master/install_nginx_proxy.sh | bash -s -- -p 8080"
}

# 解析命令行参数
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--port)
                if validate_port "$2"; then
                    PROXY_PORT="$2"
                    shift 2
                else
                    log_error "无效的端口号: $2"
                    exit 1
                fi
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# 日志函数
log_info() {
    echo -e "${BLUE}[信息]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[成功]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[警告]${NC} $1"
}

log_error() {
    echo -e "${RED}[错误]${NC} $1"
}

# 检查命令是否存在
check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# 验证端口号
validate_port() {
    local port=$1
    if [[ "$port" =~ ^[0-9]+$ ]] && [ "$port" -ge 1024 ] && [ "$port" -le 65535 ]; then
        return 0
    else
        return 1
    fi
}

# 检查端口是否被占用
check_port_available() {
    local port=$1
    
    # 简单的端口检查，尝试连接本地端口
    if curl -s --connect-timeout 1 http://127.0.0.1:$port >/dev/null 2>&1; then
        return 1  # 端口被占用
    else
        return 0  # 端口可用
    fi
}

# 获取用户端口配置
get_port_config() {
    # 如果已经通过命令行参数设置了端口，直接返回
    if [ -n "$PROXY_PORT" ]; then
        log_success "使用指定端口: $PROXY_PORT"
        return 0
    fi
    
    # 检查是否为交互式环境
    if ! is_interactive; then
        log_warning "检测到非交互式环境，使用默认端口: $DEFAULT_PORT"
        log_info "如需指定端口，请使用: curl ... | bash -s -- -p 端口号"
        PROXY_PORT=$DEFAULT_PORT
        
        # 检查默认端口是否被占用
        if ! check_port_available "$PROXY_PORT"; then
            log_warning "默认端口 $PROXY_PORT 已被占用，但将继续使用"
            log_info "如有冲突，请停止占用进程或指定其他端口"
        fi
        
        log_success "已选择端口: $PROXY_PORT"
        echo ""
        return 0
    fi
    
    # 交互式环境的端口配置
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  端口配置${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
    echo "请选择nginx监听端口："
    echo -e "${YELLOW}建议使用1024-65535范围内的端口${NC}"
    echo ""
    
    while true; do
        # 使用/dev/tty确保能够读取用户输入
        if [ -c /dev/tty ]; then
            read -p "请输入端口号 (默认: $DEFAULT_PORT): " input_port < /dev/tty
        else
            # 如果/dev/tty不可用，使用默认端口
            log_warning "无法读取用户输入，使用默认端口: $DEFAULT_PORT"
            input_port=""
        fi
        
        # 如果用户直接回车或无法读取输入，使用默认端口
        if [ -z "$input_port" ]; then
            PROXY_PORT=$DEFAULT_PORT
        else
            PROXY_PORT=$input_port
        fi
        
        # 验证端口号格式
        if ! validate_port "$PROXY_PORT"; then
            log_error "无效的端口号: $PROXY_PORT"
            log_warning "端口号必须是1024-65535之间的数字"
            continue
        fi
        
        # 检查端口是否被占用
        if ! check_port_available "$PROXY_PORT"; then
            log_warning "端口 $PROXY_PORT 已被占用"
            if [ -c /dev/tty ]; then
                read -p "是否继续使用此端口? (y/N): " continue_choice < /dev/tty
                if [[ "$continue_choice" =~ ^[Yy]$ ]]; then
                    break
                else
                    continue
                fi
            else
                log_warning "非交互式环境，将继续使用被占用的端口"
                break
            fi
        fi
        
        break
    done
    
    log_success "已选择端口: $PROXY_PORT"
    echo ""
}

# 等待用户确认
wait_for_confirm() {
    if is_interactive && [ -c /dev/tty ]; then
        read -p "按Enter键继续，或Ctrl+C退出..." < /dev/tty
    else
        log_info "非交互式环境，自动继续..."
        sleep 2
    fi
}

# 显示欢迎信息
show_welcome() {
    clear
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  Termux Nginx反向代理安装器${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
    echo "本脚本将自动完成以下操作："
    echo "1. 配置监听端口"
    echo "2. 更新Termux包管理器"
    echo "3. 安装nginx"
    echo "4. 配置nginx反向代理"
    echo "5. 启动nginx服务"
    echo "6. 验证服务状态"
    echo "7. 配置nginx自启动"
    echo ""
    echo -e "${YELLOW}目标代理: api.kurobbs.com${NC}"
    
    if ! is_interactive; then
        echo -e "${YELLOW}检测到非交互式环境，将使用默认配置${NC}"
        echo -e "${YELLOW}自启动将自动配置${NC}"
    fi
    
    echo ""
    wait_for_confirm
}

# 生成nginx配置文件
generate_nginx_config() {
    log_info "正在生成nginx配置文件..."
    
    cat > nginx.conf << EOF
worker_processes auto;
pid /data/data/com.termux/files/usr/var/run/nginx.pid;

events {
    worker_connections 768;
}

http {
    sendfile on;
    tcp_nopush on;
    underscores_in_headers on;
    server_tokens off;

    include mime.types;
    default_type application/octet-stream;

    access_log /data/data/com.termux/files/usr/var/log/nginx/access.log;
    error_log /data/data/com.termux/files/usr/var/log/nginx/error.log;

    gzip on;

    server {
        listen 0.0.0.0:$PROXY_PORT;
        server_name _;

        location / {
            proxy_pass https://api.kurobbs.com;

            proxy_set_header Host api.kurobbs.com;
            proxy_set_header X-Forwarded-Proto \$scheme;

            proxy_ssl_protocols TLSv1.2 TLSv1.3;
            proxy_ssl_ciphers 'TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384';
            proxy_ssl_server_name on;
        }
    }
}
EOF
    
    log_success "nginx配置文件生成完成 (端口: $PROXY_PORT)"
}

# 更新包管理器
update_packages() {
    log_info "正在更新包管理器..."
    if pkg update -y && pkg upgrade -y; then
        log_success "包管理器更新完成"
    else
        log_error "包管理器更新失败"
        exit 1
    fi
}

# 安装nginx
install_nginx() {
    log_info "正在安装nginx..."
    
    if check_command nginx; then
        log_warning "nginx已经安装，跳过安装步骤"
        return 0
    fi
    
    if pkg install nginx -y; then
        log_success "nginx安装完成"
    else
        log_error "nginx安装失败"
        exit 1
    fi
}

# 创建必要目录
create_directories() {
    log_info "正在创建必要目录..."
    
    mkdir -p $PREFIX/etc/nginx
    mkdir -p $PREFIX/var/log/nginx
    
    if [ -d "$PREFIX/etc/nginx" ] && [ -d "$PREFIX/var/log/nginx" ]; then
        log_success "目录创建完成"
    else
        log_error "目录创建失败"
        exit 1
    fi
}

# 部署配置文件
deploy_config() {
    log_info "正在部署nginx配置文件..."
    
    if cp nginx.conf $PREFIX/etc/nginx/; then
        log_success "配置文件部署完成"
    else
        log_error "配置文件部署失败"
        exit 1
    fi
}

# 测试配置文件
test_config() {
    log_info "正在测试nginx配置..."
    
    if nginx -t; then
        log_success "nginx配置测试通过"
    else
        log_error "nginx配置测试失败"
        log_error "请检查配置文件: $PREFIX/etc/nginx/nginx.conf"
        exit 1
    fi
}

# 检查nginx进程是否运行
check_nginx_running() {
    if ps aux | grep -v grep | grep nginx >/dev/null 2>&1; then
        return 0  # nginx正在运行
    else
        return 1  # nginx未运行
    fi
}

# 启动nginx服务
start_nginx() {
    log_info "正在启动nginx服务..."
    
    # 检查是否已经在运行
    if check_nginx_running; then
        log_warning "nginx已在运行，正在重启..."
        nginx -s reload
    else
        nginx
    fi
    
    sleep 2
    
    if check_nginx_running; then
        log_success "nginx启动成功"
    else
        log_error "nginx启动失败"
        log_error "请查看错误日志: tail -f $PREFIX/var/log/nginx/error.log"
        exit 1
    fi
}

# 验证服务状态
verify_service() {
    log_info "正在验证服务状态..."
    
    # 测试本地连接
    log_info "正在测试本地连接..."
    sleep 2  # 等待服务启动
    
    if curl -s -I --connect-timeout 5 http://127.0.0.1:$PROXY_PORT >/dev/null 2>&1; then
        log_success "127.0.0.1:$PROXY_PORT 连接测试成功"
    else
        log_warning "127.0.0.1:$PROXY_PORT 连接测试失败"
    fi
    
    if curl -s -I --connect-timeout 5 http://localhost:$PROXY_PORT >/dev/null 2>&1; then
        log_success "localhost:$PROXY_PORT 连接测试成功"
    else
        log_warning "localhost:$PROXY_PORT 连接测试失败"
    fi
}

# 配置nginx自启动
setup_autostart() {
    echo ""
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  配置自启动${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
    
    # 询问用户是否需要配置自启动
    local setup_auto=true
    if is_interactive && [ -c /dev/tty ]; then
        read -p "是否配置nginx开机自启动? (Y/n): " auto_choice < /dev/tty
        if [[ "$auto_choice" =~ ^[Nn]$ ]]; then
            setup_auto=false
        fi
    else
        log_info "非交互式环境，自动配置nginx开机自启动"
    fi
    
    if [ "$setup_auto" = false ]; then
        log_info "跳过自启动配置"
        return 0
    fi
    
    log_info "正在配置nginx自启动..."
    
    # 检测shell类型并配置自启动
    local shell_config=""
    if [ -n "$BASH_VERSION" ]; then
        shell_config="$HOME/.bashrc"
    elif [ -n "$ZSH_VERSION" ]; then
        shell_config="$HOME/.zshrc"
    else
        # 默认使用bashrc
        shell_config="$HOME/.bashrc"
    fi
    
    log_info "配置shell自启动: $shell_config"
    
    # 检查是否已经配置过自启动
    local marker="# Nginx Proxy Auto Start - RoverProxy"
    if grep -q "$marker" "$shell_config" 2>/dev/null; then
        log_warning "检测到已存在的自启动配置，正在更新..."
        # 删除旧配置
        sed -i "/$marker/,+15d" "$shell_config" 2>/dev/null || true
    fi
    
    # 添加简化的自启动配置到shell配置文件
    cat >> "$shell_config" << EOF

$marker
# 检查是否在Termux环境中并启动nginx代理
if [ -n "\$PREFIX" ] && [ -d "/data/data/com.termux" ]; then
    # 延迟3秒启动nginx（避免shell启动时的问题）
    (sleep 3 && {
        # 检查nginx是否已在运行
        if ! ps aux | grep -v grep | grep nginx >/dev/null 2>&1; then
            # 检查配置文件并启动nginx
            if [ -f "$PREFIX/etc/nginx/nginx.conf" ] && nginx -t >/dev/null 2>&1; then
                nginx && echo "\$(date): nginx代理已启动 (端口:$PROXY_PORT)" >> $PREFIX/var/log/nginx-autostart.log
            fi
        fi
    }) &
fi
# End Nginx Proxy Auto Start
EOF
    
    if [ $? -eq 0 ]; then
        log_success "自启动配置已添加到: $shell_config"
    else
        log_error "自启动配置添加失败"
        return 1
    fi
    
    log_success "nginx自启动配置完成！"
    echo ""
    log_info "自启动说明："
    echo "- 每次打开Termux时会自动启动nginx"
    echo "- 启动日志: $PREFIX/var/log/nginx-autostart.log"
    echo "- 配置文件: $shell_config"
    echo ""
    
    return 0
}

# 网络诊断函数
diagnose_network() {
    echo ""
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  网络诊断${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
    
    # 检查nginx进程
    log_info "检查nginx进程状态..."
    if check_nginx_running; then
        echo -e "${GREEN}✓${NC} nginx进程运行正常"
    else
        echo -e "${RED}✗${NC} nginx进程未运行"
        return 1
    fi
    
    # 测试本地连接
    log_info "测试本地连接..."
    
    if curl -s -I --connect-timeout 3 http://127.0.0.1:$PROXY_PORT >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} 127.0.0.1:$PROXY_PORT 可访问"
    else
        echo -e "${RED}✗${NC} 127.0.0.1:$PROXY_PORT 无法访问"
    fi
    
    if curl -s -I --connect-timeout 3 http://localhost:$PROXY_PORT >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} localhost:$PROXY_PORT 可访问"
    else
        echo -e "${RED}✗${NC} localhost:$PROXY_PORT 无法访问"
    fi
    
    echo ""
    echo -e "${YELLOW}如果本地可以访问，但外部无法访问，请检查:${NC}"
    echo "1. nginx配置是否绑定到 0.0.0.0:$PROXY_PORT"
    echo "2. 防火墙是否开放端口"
    echo "3. 网络连接是否正常"
    echo ""
}

# 显示使用信息
show_usage_info() {
    echo ""
    echo -e "${GREEN}================================${NC}"
    echo -e "${GREEN}  安装完成！${NC}"
    echo -e "${GREEN}================================${NC}"
    echo ""
    echo "服务信息："
    echo "- 监听端口: $PROXY_PORT"
    echo "- 代理目标: https://api.kurobbs.com"
    echo "- 配置文件: $PREFIX/etc/nginx/nginx.conf"
    echo "- 访问日志: $PREFIX/var/log/nginx/access.log"
    echo "- 错误日志: $PREFIX/var/log/nginx/error.log"
    echo "- 启动日志: $PREFIX/var/log/nginx-autostart.log"
    echo ""
    echo "使用方式："
    echo "- 原始地址: https://api.kurobbs.com"
    echo "- 代理地址: http://localhost:$PROXY_PORT"
    echo "- 或者: http://你的设备IP:$PROXY_PORT"
    echo ""
    echo "常用命令："
    echo "- 重启nginx: nginx -s reload"
    echo "- 停止nginx: nginx -s stop"
    echo "- 启动nginx: nginx"
    echo "- 测试配置: nginx -t"
    echo "- 查看进程: ps aux | grep nginx"
    echo "- 查看日志: tail -f $PREFIX/var/log/nginx/error.log"
    echo "- 检查端口: curl -I http://localhost:$PROXY_PORT"
    echo ""
    echo -e "${BLUE}自启动说明：${NC}"
    echo "- nginx会在每次打开Termux时自动启动"
    echo "- 如需禁用自启动，编辑 ~/.bashrc 或 ~/.zshrc"
    echo "- 删除包含 'Nginx Proxy Auto Start' 的相关行"
    echo "- 查看启动日志: tail -f $PREFIX/var/log/nginx-autostart.log"
}

# 主函数
main() {
    # 解析命令行参数
    parse_args "$@"
    
    show_welcome
    get_port_config
    generate_nginx_config
    update_packages
    install_nginx
    create_directories
    deploy_config
    test_config
    start_nginx
    verify_service
    diagnose_network
    setup_autostart
    show_usage_info
}

# 错误处理
set -e
trap 'log_error "脚本执行失败，请检查错误信息"' ERR

# 运行主函数，传递所有参数
main "$@"

log_success "脚本执行完成！" 
