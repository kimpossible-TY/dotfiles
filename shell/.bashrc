# =====================================================================
# 대화형 셸(Interactive Shell) 검사 및 ble.sh 사전 로드
# =====================================================================
if [[ $- == *i* ]]; then
    # Dockerfile에서 설치한 전역 경로에 ble.sh가 존재하는지 확인
    if [ -f "/usr/local/share/ble/ble.sh" ]; then
        source "/usr/local/share/ble/ble.sh" --noattach
    fi
fi

export WORKSPACE="${WORKSPACE:-$HOME/workspace}"

# =====================================================================
#  ble.sh 렌더링 엔진 터미널에 부착 (Attach)
# =====================================================================
if [[ ${BLE_VERSION-} ]]; then
    ble-attach
fi