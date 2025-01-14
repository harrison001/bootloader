#!/bin/bash

echo "Cleaning repository..."

# 创建临时目录并复制需要的文件
mkdir -p ../temp_repo
cp -r * ../temp_repo/
cd ../temp_repo

# 初始化新的仓库
git init -b main

# 创建 .gitignore
cat > .gitignore << EOL
# 大文件
*.img
*.qcow2
*.bin
.DS_Store
**/.DS_Store

# 特定文件
SentinelDOS/freedos.img
SentinelDOS/FD13FULL.qcow2
EOL

# 添加并提交文件
git add .
git commit -m "Initial commit"

# 设置远程仓库
git remote add origin git@github.com:harrison001/bootloader.git

# 添加 workable 标签
git tag -a "workable_v1" -m "First workable version"

# 强制推送到 main 分支和标签
git push -f origin main
git push -f origin workable_v1

# 返回原目录并清理
cd ../bootloader
rm -rf ../temp_repo

echo "Done! Repository cleaned and tagged as 'workable_v1'" 