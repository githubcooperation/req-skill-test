#!/bin/bash
# run-complete.sh — 向后兼容包装器，调用 run-skill.sh
# Usage: ./run-complete.sh <eval-dir> [model]
# Example: ./run-complete.sh req-skill-reviewer-workspace/evals/test-complete-1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/run-skill.sh" \
  "${1:?Usage: $0 <eval-dir> [model]}" \
  "请使用req-complete技能处理输入文档，自动补全，不用问我，直接按行业最佳实践填充" \
  "${2:-opencode/minimax-m2.5-free}"
