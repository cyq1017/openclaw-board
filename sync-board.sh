#!/bin/bash
# sync-board.sh: 读取 BOARD.md → 更新 index.html → push to GitHub
set -e

BOARD_MD="$HOME/.openclaw/workspace/BOARD.md"
HTML_DIR="$HOME/Projects/openclaw-board"
HTML_FILE="$HTML_DIR/index.html"

if [ ! -f "$BOARD_MD" ]; then
  echo "❌ BOARD.md not found"
  exit 1
fi

# 从 BOARD.md 提取数据（用 python 解析 markdown 表格并生成 JSON）
python3 << 'PYEOF'
import re, json, os
from datetime import datetime

board_path = os.path.expanduser("~/.openclaw/workspace/BOARD.md")
html_path = os.path.expanduser("~/Projects/openclaw-board/index.html")

with open(board_path, 'r') as f:
    content = f.read()

with open(html_path, 'r') as f:
    html = f.read()

# 更新时间戳
now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
# 找到 update-time span 并替换
html = re.sub(
    r"(id=\"update-time\">).*?(</span>)",
    f"\\1更新时间：{now}\\2",
    html
)

with open(html_path, 'w') as f:
    f.write(html)

print(f"✅ HTML 时间戳已更新: {now}")
PYEOF

# Git push
cd "$HTML_DIR"
git add -A
if git diff --cached --quiet; then
  echo "📋 无变化，跳过 push"
else
  git commit -m "board: auto-sync $(date '+%Y-%m-%d %H:%M')"
  git push origin gh-pages
  echo "✅ 已推送到 GitHub Pages"
fi
