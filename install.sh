#!/bin/bash
# ~/dotfiles/install.sh

cd "$(dirname "$0")"

# 1. 기존에 Codespaces가 기본으로 만들어둔 순정 .bashrc가 있다면 Stow가 충돌을 일으키므로 과감하게 제거
if [ -f ~/.bashrc ] && [ ! -L ~/.bashrc ]; then
    rm -f ~/.bashrc
fi

# 2. shell 패키지를 stow하여 내 .bashrc를 홈 디렉터리에 연결
stow -t ~ shell
stow -t ~ nvim

echo "모든 Dotfiles 동기화 완료!"