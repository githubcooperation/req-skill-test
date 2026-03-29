#!/bin/bash
# run-skill.sh — 统一子技能测试 runner
# Usage: ./run-skill.sh <eval-dir> <prompt> [model]
# Examples:
#   ./run-skill.sh req-skill-reviewer-workspace/evals/test-complete-1 \
#     "请使用req-complete技能处理 docs/interview.md，自动补全，不用问我" \
#     opencode/minimax-m2.5-free
#
#   ./run-skill.sh req-skill-reviewer-workspace/evals/test-complete-4 \
#     "请使用req-complete技能处理 docs/meeting.md，自动补全，不用问我"

set -e

EVAL_DIR="${1:?Usage: $0 <eval-dir> <prompt> [model]}"
PROMPT="${2:?Usage: $0 <eval-dir> <prompt> [model]}"
MODEL="${3:-opencode/minimax-m2.5-free}"

EVAL_ABS="$(cd "$EVAL_DIR" && pwd)"
OUTPUT_DIR="$EVAL_ABS/output"

echo "=== [run-skill] 目录: $EVAL_ABS ==="
echo "=== [run-skill] 模型: $MODEL ==="
echo ""

cd "$EVAL_ABS"
opencode run --model "$MODEL" "$PROMPT"

echo ""
echo "=== [run-skill] opencode 完成，执行产物修复 ==="

# ─── req-complete 修复：插入缺失的 {低保真原型图} ───────────────────────────
PRD_FILE="$OUTPUT_DIR/prd-updated.md"
if [ -f "$PRD_FILE" ]; then
  PRD_FILE="$PRD_FILE" python3 -c "
import os
f = os.environ['PRD_FILE']
lines = open(f).readlines()
out, buf = [], []
for ln in lines:
    if ln.strip() == '---':
        if any(l.startswith('#') for l in buf) and '{低保真原型图}' not in ''.join(buf):
            out += ['\n', '{低保真原型图}\n', '\n']
        buf = []
    else:
        buf.append(ln)
    out.append(ln)
open(f, 'w').writelines(out)
n = open(f).read().count('{低保真原型图}')
print(f'[repair:prd] {n} 个 {{低保真原型图}} 占位符已确认')
"
fi

# ─── 可在此处扩展其他子技能的产物修复 ─────────────────────────────────────
# req-review: 暂无自动修复（格式由模型保证）
# req-testcase: 暂无自动修复
# req-wireframe: 暂无自动修复（截图失败时保留占位符）
# req-flowdoc: 暂无自动修复

echo "=== [run-skill] 完成 ==="
