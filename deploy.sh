#!/bin/bash
# ============================================
# 部署替换脚本 - 将 frog.co 域名替换为 IP
# 用法: bash deploy.sh
# ============================================

TARGET_IP="127.0.0.1"
PROJECT_DIR="/var/www/website/zgx"

echo "========================================="
echo " 开始替换域名引用为 IP: ${TARGET_IP}"
echo "========================================="

# 1. 替换绝对URL引用 (https://www.frog.co -> http://127.0.0.1)
find "${PROJECT_DIR}" -type f \( -name "*.html" -o -name "*.js" -o -name "*.txt" -o -name "*.xml" -o -name "*.json" \) \
  -exec sed -i "s|https://www\.frog\.co|http://${TARGET_IP}|g" {} +

# 2. 替换 http://www.frog.co (JS中的API基础URL)
find "${PROJECT_DIR}" -type f \( -name "*.html" -o -name "*.js" \) \
  -exec sed -i "s|http://www\.frog\.co|http://${TARGET_IP}|g" {} +

# 3. 替换 https://frog.co (不带www)
find "${PROJECT_DIR}" -type f \( -name "*.html" -o -name "*.js" -o -name "*.txt" \) \
  -exec sed -i "s|https://frog\.co|http://${TARGET_IP}|g" {} +

# 4. 替换 https://wp.frog.co (WordPress媒体资源)
find "${PROJECT_DIR}" -type f \( -name "*.html" -o -name "*.js" \) \
  -exec sed -i "s|https://wp\.frog\.co|http://${TARGET_IP}/wp|g" {} +

# 5. 替换 https://go.frog.co (Pardot表单)
find "${PROJECT_DIR}" -type f \( -name "*.html" -o -name "*.js" \) \
  -exec sed -i "s|https://go\.frog\.co|http://${TARGET_IP}/go|g" {} +

# 6. 替换 https://frogco.cn (中国站)
find "${PROJECT_DIR}" -type f \( -name "*.html" -o -name "*.js" \) \
  -exec sed -i "s|https://frogco\.cn|http://${TARGET_IP}|g" {} +

# 7. 替换相对路径引用 ../www.frog.co/ -> / (因为www.frog.co就是根站点)
find "${PROJECT_DIR}" -type f -name "*.html" \
  -exec sed -i 's|\.\./www\.frog\.co/|/|g' {} +

# 8. 替换相对路径引用 ../wp.frog.co/ -> /wp/
find "${PROJECT_DIR}" -type f -name "*.html" \
  -exec sed -i 's|\.\./wp\.frog\.co/|/wp/|g' {} +

# 9. 替换相对路径引用 ../go.frog.co/ -> /go/
find "${PROJECT_DIR}" -type f -name "*.html" \
  -exec sed -i 's|\.\./go\.frog\.co/|/go/|g' {} +

# 10. 替换相对路径 ../../frog.co/ -> / (go.frog.co中引用frog.co)
find "${PROJECT_DIR}" -type f -name "*.html" \
  -exec sed -i 's|\.\./\.\./frog\.co/|/|g' {} +

# 11. 替换 ../frog.co/ -> / (go.frog.co中引用frog.co)
find "${PROJECT_DIR}" -type f -name "*.html" \
  -exec sed -i 's|\.\./frog\.co/|/|g' {} +

# 12. 替换 robots.txt 中的 sitemap URL
find "${PROJECT_DIR}" -type f -name "robots.txt" \
  -exec sed -i "s|https://www\.frog\.co|http://${TARGET_IP}|g" {} +

echo "========================================="
echo " 域名替换完成！"
echo "========================================="