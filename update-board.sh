#!/bin/bash
WORKSPACE="$HOME/.openclaw/workspace"
BOARD_MD="$WORKSPACE/BOARD.md"
BOARD_HTML="$WORKSPACE/BOARD.html"

if [ ! -f "$BOARD_MD" ]; then
  echo "BOARD.md not found"
  exit 1
fi

CONTENT=$(cat "$BOARD_MD")
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

cat > "$BOARD_HTML" << 'HTMLEOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>AI 团队看板</title>
<style>
* { margin: 0; padding: 0; box-sizing: border-box; }
body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Helvetica, Arial, sans-serif;
  background: #0d1117; color: #c9d1d9; padding: 24px; line-height: 1.6;
}
.container { max-width: 960px; margin: 0 auto; }
h1 { color: #58a6ff; font-size: 28px; margin-bottom: 8px; }
.timestamp { color: #8b949e; font-size: 13px; margin-bottom: 24px; }
h2 { color: #f0f6fc; font-size: 20px; margin: 24px 0 12px; padding-bottom: 8px; border-bottom: 1px solid #21262d; }
hr { border: none; border-top: 1px solid #21262d; margin: 20px 0; }
table { width: 100%; border-collapse: collapse; margin: 12px 0; }
th { background: #161b22; color: #8b949e; text-align: left; padding: 10px 12px; font-size: 13px; font-weight: 600; border-bottom: 1px solid #30363d; }
td { padding: 10px 12px; border-bottom: 1px solid #21262d; font-size: 14px; }
tr:hover td { background: #161b22; }
.card { background: #161b22; border: 1px solid #30363d; border-radius: 8px; padding: 16px; margin: 8px 0; }
.status-online { color: #3fb950; }
.status-offline { color: #f85149; }
p { margin: 8px 0; }
blockquote { border-left: 3px solid #30363d; padding-left: 12px; color: #8b949e; margin: 8px 0; }
</style>
</head>
<body>
<div class="container">
HTMLEOF

python3 -c "
import re, html

md = open('$BOARD_MD').read()
lines = md.split('\n')
in_table = False
print('<h1>🦞 AI 团队看板</h1>')
print('<p class=\"timestamp\">更新时间：$TIMESTAMP</p>')

for line in lines:
    line_s = line.strip()
    if not line_s:
        if in_table:
            print('</tbody></table>')
            in_table = False
        continue
    if line_s.startswith('# '):
        continue
    if line_s.startswith('> '):
        print(f'<blockquote>{html.escape(line_s[2:])}</blockquote>')
    elif line_s.startswith('## '):
        if in_table:
            print('</tbody></table>')
            in_table = False
        print(f'<h2>{html.escape(line_s[3:])}</h2>')
    elif line_s.startswith('---'):
        if in_table:
            print('</tbody></table>')
            in_table = False
        print('<hr>')
    elif line_s.startswith('|'):
        cells = [c.strip() for c in line_s.split('|')[1:-1]]
        if all(set(c) <= set('- ') for c in cells):
            continue
        if not in_table:
            in_table = True
            print('<table><thead><tr>')
            for c in cells:
                print(f'<th>{html.escape(c)}</th>')
            print('</tr></thead><tbody>')
        else:
            print('<tr>')
            for c in cells:
                text = html.escape(c)
                if '在线' in c:
                    text = f'<span class=\"status-online\">{text}</span>'
                print(f'<td>{text}</td>')
            print('</tr>')
    elif line_s.startswith('（') or line_s.startswith('('):
        print(f'<p style=\"color:#8b949e\">{html.escape(line_s)}</p>')
    else:
        print(f'<p>{html.escape(line_s)}</p>')

if in_table:
    print('</tbody></table>')
" >> "$BOARD_HTML"

cat >> "$BOARD_HTML" << 'HTMLEOF'
</div>
</body>
</html>
HTMLEOF

echo "BOARD.html updated at $TIMESTAMP"
