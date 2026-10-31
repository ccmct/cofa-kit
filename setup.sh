#!/usr/bin/env bash
# cofa-kit 설치
# 사용법: 과제 폴더에서  bash /tmp/cofa-kit-ccmct/setup.sh   (또는 bash setup.sh [과제 폴더])
#   - 지침 AGENTS.md 를 과제 폴더에 둔다 (과제 폴더에 이미 다른 AGENTS.md 가 있으면 건드리지 않고 알려 준다)
#   - 스킬을 과제 폴더의 cofa-skills/ 에 복사한다 (이미 있는 파일은 덮어쓰지 않는다)
#   - 과제 폴더에 WORKLOG.md 가 없으면 만든다 (있으면 건드리지 않는다)
# 홈 폴더의 전역 설정(~/.codex, ~/.agents)은 건드리지 않는다. 환경에 따라 쓰기가 막혀 있을 수 있고,
# 과제 폴더에 두어야 내가 AI에 준 지침이 작업물과 함께 남는다.
# 여러 번 실행해도 안전하다.
set -uo pipefail

KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK="$(cd "${1:-$PWD}" && pwd)"
FAIL=0
CONFLICT=0

if [ ! -e "$WORK/README.md" ]; then
  echo "[확인] $WORK 에 README.md 가 없습니다. 과제 폴더에서 실행했는지 확인하세요. (설치는 계속합니다)"
fi

# 1) 지침
if [ ! -e "$WORK/AGENTS.md" ]; then
  if cp "$KIT/AGENTS.md" "$WORK/AGENTS.md"; then
    echo "[1/3] 지침 설치: $WORK/AGENTS.md"
  else
    echo "[1/3] 실패: AGENTS.md 복사"; FAIL=1
  fi
elif grep -q "cofa-kit" "$WORK/AGENTS.md"; then
  echo "[1/3] 지침이 이미 설치돼 있어 건너뜀"
else
  echo "[1/3] 과제 폴더에 다른 AGENTS.md 가 이미 있어 건드리지 않았습니다."
  echo "      과제가 준 파일일 수 있습니다. 합칠지 직접 정하세요. 내 지침 원본: $KIT/AGENTS.md"
  CONFLICT=1
fi

# 2) 스킬
mkdir -p "$WORK/cofa-skills" || FAIL=1
for d in "$KIT"/skills/*/; do
  name="$(basename "$d")"
  if [ -e "$WORK/cofa-skills/$name" ]; then
    echo "[2/3] 스킬 $name 이미 있음, 건너뜀"
  elif cp -r "$d" "$WORK/cofa-skills/$name"; then
    echo "[2/3] 스킬 설치: cofa-skills/$name"
  else
    echo "[2/3] 실패: 스킬 $name 복사"; FAIL=1
  fi
done

# 3) 작업 기록
if [ -e "$WORK/WORKLOG.md" ]; then
  echo "[3/3] WORKLOG.md 이미 있음, 건너뜀"
elif cp "$KIT/templates/WORKLOG.md" "$WORK/WORKLOG.md"; then
  echo "[3/3] 작업 기록 파일 생성: $WORK/WORKLOG.md"
else
  echo "[3/3] 실패: WORKLOG.md 생성"; FAIL=1
fi

echo
if [ "$CONFLICT" -ne 0 ]; then
  echo "AGENTS.md 는 직접 정해야 합니다. 과제 파일이면 건드리지 말고, Codex를 켠 뒤 첫 메시지로"
  echo "  '$KIT/AGENTS.md 를 읽고 그 지침을 따라줘. 과제 AGENTS.md와 다르면 과제가 우선이야'"
  echo "라고 말하세요."
fi
if [ "$FAIL" -ne 0 ]; then
  echo "일부 단계가 끝나지 않았습니다. PLAYBOOK 1번의 '설치가 안 될 때' 명령으로 직접 복사하세요."
  exit 1
fi
[ "$CONFLICT" -ne 0 ] && exit 1
echo "완료. 이미 켜 둔 Codex가 있으면 /quit 으로 끄고, 이 폴더에서 다시 codex 를 실행하세요."
echo "확인: Codex에게 '지금 적용된 지침을 3줄로 요약하고, cofa-skills 목록을 말해줘' 라고 물어보면 됩니다."
