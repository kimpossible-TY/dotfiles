#!/bin/bash

# 1. SSH 디렉토리 생성 및 권한 설정
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# 2. GitHub Secret(SSH_KEY)에서 개인키 복원
if [ -n "$SSH_KEY" ]; then
    echo "Restoring SSH Key..."
    echo "$SSH_KEY" > ~/.ssh/id_ed25519
    chmod 600 ~/.ssh/id_ed25519
    
    # 3. GitHub 서버 신뢰 목록 등록 (Permission Denied 방지 핵심)
    ssh-keyscan -t ed25519 github.com >> ~/.ssh/known_hosts
    chmod 644 ~/.ssh/known_hosts
    
    echo "SSH restoration complete."
else
    echo "Error: SSH_KEY secret is missing. Check your GitHub Settings."
fi
