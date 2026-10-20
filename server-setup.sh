#!/bin/bash
# ============================================
# 一键部署脚本 - 在Linux服务器上执行
# 用法: sudo bash server-setup.sh
# ============================================

SERVER_IP="127.0.0.1"
WEB_ROOT="/var/www/website/zgx"
CADDY_LOG="/var/log/caddy"

echo "========================================="
echo " 第1步: 安装 Caddy"
echo "========================================="

# 安装 Caddy (Debian/Ubuntu)
sudo apt update
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install -y caddy

echo "========================================="
echo " 第2步: 创建目录结构"
echo "========================================="

sudo mkdir -p ${WEB_ROOT}
sudo mkdir -p ${CADDY_LOG}

echo "========================================="
echo " 第3步: 执行域名替换"
echo "========================================="

# 替换绝对URL
find "${WEB_ROOT}" -type f \( -name "*.html" -o -name "*.js" -o -name "*.txt" -o -name "*.xml" -o -name "*.json" \) \
  -exec sed -i "s|https://www\.frog\.co|http://${SERVER_IP}|g" {} +

find "${WEB_ROOT}" -type f \( -name "*.html" -o -name "*.js" \) \
  -exec sed -i "s|http://www\.frog\.co|http://${SERVER_IP}|g" {} +

find "${WEB_ROOT}" -type f \( -name "*.html" -o -name "*.js" -o -name "*.txt" \) \
  -exec sed -i "s|https://frog\.co/|http://${SERVER_IP}/|g" {} +

find "${WEB_ROOT}" -type f \( -name "*.html" -o -name "*.js" \) \
  -exec sed -i "s|https://wp\.frog\.co|http://${SERVER_IP}/wp|g" {} +

find "${WEB_ROOT}" -type f \( -name "*.html" -o -name "*.js" \) \
  -exec sed -i "s|https://go\.frog\.co|http://${SERVER_IP}/go|g" {} +

find "${WEB_ROOT}" -type f \( -name "*.html" -o -name "*.js" \) \
  -exec sed -i "s|https://frogco\.cn|http://${SERVER_IP}|g" {} +

# 替换相对路径
find "${WEB_ROOT}" -type f -name "*.html" -exec sed -i 's|\.\./www\.frog\.co/|/|g' {} +
find "${WEB_ROOT}" -type f -name "*.html" -exec sed -i 's|\.\./wp\.frog\.co/|/wp/|g' {} +
find "${WEB_ROOT}" -type f -name "*.html" -exec sed -i 's|\.\./go\.frog\.co/|/go/|g' {} +
find "${WEB_ROOT}" -type f -name "*.html" -exec sed -i 's|\.\./\.\./frog\.co/|/|g' {} +
find "${WEB_ROOT}" -type f -name "*.html" -exec sed -i 's|\.\./frog\.co/|/|g' {} +

echo "========================================="
echo " 第4步: 配置 Caddy"
echo "========================================="

cat > /etc/caddy/Caddyfile << 'CADDYEOF'
127.0.0.1 {
    root * /var/www/website/zgx/www.frog.co
    encode gzip

    @static path /_next/static/* /static/* /fonts/* /favicon.ico *.woff2 *.woff *.ttf *.eot *.svg *.png *.jpg *.jpeg *.gif *.mp4 *.webm
    header @static Cache-Control "public, max-age=31536000, immutable"

    @html {
        path *.html /
        not path /_next/static/*
    }
    header @html Cache-Control "no-cache, no-store, must-revalidate"

    try_files {path} {path}.html /index.html
    file_server

    handle_path /wp/* {
        root * /var/www/website/zgx/wp.frog.co
        try_files {path} /index.html
        file_server
    }

    handle_path /go/* {
        root * /var/www/website/zgx/go.frog.co
        try_files {path} /index.html
        file_server
    }

    handle_path /frog/* {
        root * /var/www/website/zgx/frog.co
        try_files {path} /index.html
        file_server
    }

    handle_path /cannes/* {
        root * /var/www/website/zgx/cannes.frog.co/cannes.frog.co
        try_files {path} /index.html
        file_server
    }

    handle_path /cards/* {
        root * /var/www/website/zgx/cardsforsustainability.frog.co/cardsforsustainability.frog.co
        try_files {path} /index.html
        file_server
    }

    handle_path /milan/* {
        root * /var/www/website/zgx/milandesignweek.frog.co
        try_files {path} /index.html
        file_server
    }

    log {
        output file /var/log/caddy/frog.log
        format json
    }
}
CADDYEOF

echo "========================================="
echo " 第5步: 设置文件权限并启动 Caddy"
echo "========================================="

sudo chown -R caddy:caddy ${WEB_ROOT}
sudo chown -R caddy:caddy ${CADDY_LOG}
sudo systemctl enable caddy
sudo systemctl restart caddy

echo "========================================="
echo " 部署完成！"
echo " 访问: http://${SERVER_IP}"
echo "========================================="

# 检查Caddy状态
sudo systemctl status caddy --no-pager