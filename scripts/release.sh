#!/usr/bin/env bash
# prod 빌드를 Play 비공개 테스트 · TestFlight에 올린다.
#
#   scripts/release.sh                 빌드 번호 +1, 둘 다
#   scripts/release.sh --name 1.0.2    버전 이름도 바꾼다
#   scripts/release.sh --android       한쪽만 (--ios)
#
# 키는 레포 밖 ~/.soiduty/release.env 에서 읽는다:
#   PLAY_JSON_KEY=~/.soiduty/play-service-account.json
#   PLAY_TRACK=alpha
#   ASC_KEY_ID=XXXXXXXXXX
#   ASC_ISSUER_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
#   ASC_KEY_PATH=~/.soiduty/AuthKey_XXXXXXXXXX.p8
set -euo pipefail

cd "$(dirname "$0")/.."

ENV_FILE="${SOIDUTY_RELEASE_ENV:-$HOME/.soiduty/release.env}"
PACKAGE=com.nuyoes.soiduty

do_android=1
do_ios=1
new_name=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --android) do_ios=0 ;;
    --ios) do_android=0 ;;
    --name) new_name="$2"; shift ;;
    *) echo "알 수 없는 옵션: $1" >&2; exit 1 ;;
  esac
  shift
done

step() { printf '\n\033[1;32m▶ %s\033[0m\n' "$*"; }
die() { printf '\033[1;31m✗ %s\033[0m\n' "$*" >&2; exit 1; }

# ----- 준비 확인 -----
[[ -f "$ENV_FILE" ]] || die "$ENV_FILE 이 없다"
# shellcheck source=/dev/null
source "$ENV_FILE"
expand() { eval echo "$1"; }  # ~ 확장

if (( do_android )); then
  PLAY_JSON_KEY="$(expand "${PLAY_JSON_KEY:?PLAY_JSON_KEY 없음}")"
  PLAY_TRACK="${PLAY_TRACK:-alpha}"
  [[ -f "$PLAY_JSON_KEY" ]] || die "Play 서비스 계정 키가 없다: $PLAY_JSON_KEY"
  [[ -f android/key.properties ]] || die "android/key.properties 가 없다 (업로드 키 서명)"
fi
if (( do_ios )); then
  : "${ASC_KEY_ID:?ASC_KEY_ID 없음}" "${ASC_ISSUER_ID:?ASC_ISSUER_ID 없음}"
  ASC_KEY_PATH="$(expand "${ASC_KEY_PATH:?ASC_KEY_PATH 없음}")"
  [[ -f "$ASC_KEY_PATH" ]] || die "App Store Connect API 키가 없다: $ASC_KEY_PATH"
fi

[[ -z "$(git status --porcelain)" ]] || die "커밋 안 된 변경이 있다"

# ----- 테스트 -----
step "flutter test"
flutter test

# ----- 버전 -----
current="$(grep -E '^version:' pubspec.yaml | sed -E 's/version: *//')"
name="${current%+*}"
build="${current#*+}"
[[ -n "$new_name" ]] && name="$new_name"
version="$name+$((build + 1))"
step "버전 $current → $version"
sed -i '' -E "s/^version: .*/version: $version/" pubspec.yaml
git commit -qm "버전 $version" pubspec.yaml

# ----- Android -----
if (( do_android )); then
  step "Android 빌드"
  flutter build appbundle --flavor prod --release
  aab=build/app/outputs/bundle/prodRelease/app-prod-release.aab

  step "Play 업로드 ($PLAY_TRACK)"
  fastlane run upload_to_play_store \
    package_name:"$PACKAGE" \
    json_key:"$PLAY_JSON_KEY" \
    aab:"$aab" \
    track:"$PLAY_TRACK" \
    release_status:completed \
    skip_upload_metadata:true \
    skip_upload_changelogs:true \
    skip_upload_images:true \
    skip_upload_screenshots:true
fi

# ----- iOS -----
if (( do_ios )); then
  step "iOS 빌드"
  flutter build ipa --flavor prod --release --export-options-plist=ios/ExportOptions.plist
  ipa="$(ls build/ios/ipa/*.ipa | head -1)"

  step "TestFlight 업로드"
  # fastlane은 키 내용을 담은 JSON을 받는다. 임시 파일로 만들고 끝나면 지운다.
  api_json="$(mktemp)"
  trap 'rm -f "$api_json"' EXIT
  ruby -rjson -e 'puts({key_id: ARGV[0], issuer_id: ARGV[1], key: File.read(ARGV[2])}.to_json)' \
    "$ASC_KEY_ID" "$ASC_ISSUER_ID" "$ASC_KEY_PATH" > "$api_json"
  fastlane run upload_to_testflight \
    api_key_path:"$api_json" \
    ipa:"$ipa" \
    skip_waiting_for_build_processing:true
fi

step "완료: $version"
echo "push는 따로: git push"
