#!/bin/bash

# 1. SSH 디렉토리 생성 및 권한 설정
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# 2. GitHub Secret(SSH_KEY)에서 개인키 복원
if [ -n "$SSH_KEY" ]; then
    echo "Restoring SSH Key..."
    echo "$SSH_KEY" > ~/.ssh/id_ed25519
    chmod 600 ~/.ssh/id_ed25519
    
    # 3. GitHub 서버 신뢰 목록 등록
    ssh-keyscan -t ed25519 github.com >> ~/.ssh/known_hosts
    chmod 644 ~/.ssh/known_hosts
    
    echo "SSH restoration complete."
else
    echo "Error: SSH_KEY secret is missing. Check your GitHub Settings."
fi

# 4. .bashrc에 비대화형 쉘 종료 로직 삽입 (추가된 부분)
BASHRC="$HOME/.bashrc"
INSERT_LINE='[ -z "$PS1" ] && return'

if [ -f "$BASHRC" ]; then
    # 이미 해당 문구가 있는지 확인
    if ! grep -qxF "$INSERT_LINE" "$BASHRC"; then
        echo "Updating .bashrc to prevent non-interactive output errors..."
        # 파일의 가장 첫 줄에 삽입 (매우 중요: 모든 출력 코드보다 위에 있어야 함)
        sed -i "1i $INSERT_LINE" "$BASHRC"
    fi
else
    # .bashrc가 없는 경우 새로 생성
    echo "$INSERT_LINE" > "$BASHRC"
fi

echo "Environment setup complete."
