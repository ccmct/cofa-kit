#!/usr/bin/env bash
# cofa-kit 설치
# 사용법: 과제 폴더에서  bash ~/cofa-kit/setup.sh
#   - 전역 AGENTS.md(~/.codex/AGENTS.md)에 개인 지침을 설치한다 (기존 파일이 있으면 백업 후 뒤에 붙인다)
#   - 스킬을 ~/.agents/skills 에 복사한다
#   - 현재 폴더에 WORKLOG.md 가 없으면 만든다 (있으면 건드리지 않는다)
set -euo pipefail

KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK="${1:-$PWD}"
CODEX_DIR="${CODEX_HOME:-$HOME/.codex}"
GLOBAL="$CODEX_DIR/AGENTS.md"

mkdir -p "$CODEX_DIR"
if [ ! -f "$GLOBAL" ]; then
  cp "$KIT/AGENTS.md" "$GLOBAL"
  echo "[1/3] 전역 지침 설치: $GLOBAL"
elif grep -q "cofa-kit" "$GLOBAL"; then
  echo "[1/3] 전역 지침이 이미 설치돼 있어 건너뜀"
else
  cp "$GLOBAL" "$GLOBAL.bak"
  { printf '\n\n'; cat "$KIT/AGENTS.md"; } >> "$GLOBAL"
  echo "[1/3] 기존 전역 지침 뒤에 추가 (백업: $GLOBAL.bak)"
fi

mkdir -p "$HOME/.agents/skills"
cp -r "$KIT/skills/." "$HOME/.agents/skills/"
echo "[2/3] 스킬 복사: $HOME/.agents/skills ($(ls "$KIT/skills" | tr '\n' ' '))"

if [ -e "$WORK/WORKLOG.md" ]; then
  echo "[3/3] $WORK/WORKLOG.md 이미 있음, 건너뜀"
else
  cp "$KIT/templates/WORKLOG.md" "$WORK/WORKLOG.md"
  echo "[3/3] 작업 기록 파일 생성: $WORK/WORKLOG.md"
fi

echo
echo "완료. 이미 켜 둔 Codex가 있으면 /quit 으로 끄고 다시 codex 를 실행하세요."
echo "확인: Codex에게 '지금 적용된 지침을 3줄로 요약해줘' 라고 물어보면 됩니다."
