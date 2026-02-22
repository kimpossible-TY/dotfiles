#!/bin/bash

echo "Starting dotfiles installation..."

# 1. SSH 디렉토리 준비
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# 2. GitHub Secret(SSH_KEY)을 파일로 복원
# (Secret 이름이 SSH_KEY라고 가정합니다)
if [ -n "$SSH_KEY" ]; then
    echo "Restoring SSH Key from GitHub Secrets..."
    echo "$SSH_KEY" > ~/.ssh/id_rsa
    chmod 600 ~/.ssh/id_rsa
    
    # GitHub 서버를 신뢰할 수 있는 호스트로 등록 (Permission denied 방지 핵심)
    ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
    echo "SSH Key restored successfully."
else
    echo "Error: SSH_KEY secret not found. Check Codespace Secrets settings."
fi

# 3. 추가적인 개인 설정 (예: Alias)
# 여기에 필요한 설정 파일들을 심볼릭 링크로 연결하는 로직을 추가할 수 있습니다.
