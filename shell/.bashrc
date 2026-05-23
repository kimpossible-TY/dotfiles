# =====================================================================
# 1. 대화형 셸(Interactive Shell) 검사 및 ble.sh 사전 로드
# =====================================================================
if [[ $- == *i* ]]; then
    if [ -f "/usr/local/share/ble/ble.sh" ]; then
        source "/usr/local/share/ble/ble.sh" --noattach
    fi
fi

export WORKSPACE="${WORKSPACE:-$HOME/workspace}"

# =====================================================================
# 2. Git 브랜치 정보 추출 함수
# =====================================================================
function parse_git_branch {
    # Git 저장소 안인지 확인하고 브랜치명만 추출
    local branch
    branch=$(git branch --show-current 2> /dev/null)
    if [[ -n "$branch" ]]; then
        # 변경 사항(Staging, Unstaged 등)이 있으면 * 표시 추가
        local status_clean
        if [[ -z $(git status --porcelain 2> /dev/null) ]]; then
            status_clean=""
        else
            status_clean="*"
        fi
        # 파란색 괄호 안에 보라색으로 브랜치명 표시: (main*)
        echo -e " \[\e[34m\](\[\e[35m\]${branch}${status_clean}\[\e[34m\])"
    fi
}

# =====================================================================
# 3. 터미널 프롬프트 (PS1) 디자인 커스텀
# =====================================================================
# PROMPT_COMMAND를 사용해 매 명령어가 끝날 때마다 Git 상태를 동적으로 업데이트합니다.
function set_prompt {
    local exit_code=$? # 이전 명령어의 성공/실패 여부 저장
    
    # 디렉토리: 시안색(\e[36m)
    local dir_color="\[\e[36m\]\w\[\e[0m\]"
    
    # 이전 명령어가 실패했다면 화살표를 빨간색으로, 성공했다면 초록색으로 표시
    local arrow_color="\[\e[32m\]"
    if [ $exit_code -ne 0 ]; then
        arrow_color="\[\e[31m\]"
    fi
    
    # 최종 PS1 조립: [경로] [Git브랜치] (줄바꿈) ❯
    export PS1="${dir_color}\$(parse_git_branch)\n${arrow_color}❯\[\e[0m\] "
}

# 매 셸 프롬프트가 렌더링될 때마다 set_prompt 함수 실행
if [[ $COLORTERM == *truecolor* ]] || [[ $TERM == *256color* ]]; then
    export PROMPT_COMMAND=set_prompt
else
    # 컬러를 지원하지 않는 기본 환경용 
    export PS1="\w\n❯ "
fi

# =====================================================================
# 4. ble.sh 렌더링 엔진 부착 및 테마 설정
# =====================================================================
if [[ ${BLE_VERSION-} ]]; then
    # ble.sh 내부 기본 테마 설정 (bright가 가독성이 좋습니다)
    bleopt color_theme='bright'
    
    # 최종 부착
    ble-attach
fi