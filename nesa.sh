#!/bin/bash

BOLD='\033[1m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
CYAN='\033[36m'
MAGENTA='\033[35m'
NC='\033[0m'

# 한국어 체크하기
check_korean_support() {
    if locale -a | grep -q "ko_KR.utf8"; then
        return 0  # Korean support is installed
    else
        return 1  # Korean support is not installed
    fi
}

# 한국어 IF
if check_korean_support; then
    echo -e "${CYAN}한글있긔 설치넘기긔.${NC}"
else
    echo -e "${CYAN}한글없긔, 설치하겠긔.${NC}"
    sudo apt-get install language-pack-ko -y
    sudo locale-gen ko_KR.UTF-8
    sudo update-locale LANG=ko_KR.UTF-8 LC_MESSAGES=POSIX
    echo -e "${CYAN}설치 완료했긔.${NC}"
fi

# 기본 구성 설치

command_exists() {
    command -v "$1" &> /dev/null
}

echo -e "${CYAN}sudo apt update${NC}"
sudo apt update -y

if command_exists jq; then
    echo -e "${GREEN}jq is already installed: $(jq --version)${NC}"
else
    echo -e "${YELLOW}Installing jq...${NC}"
    sudo apt-get install -y jq
    echo -e "${GREEN}jq installed: $(jq --version)${NC}"
fi

if command_exists curl; then
    echo -e "${GREEN}curl is already installed: $(curl --version | head -n 1)${NC}"
else
    echo -e "${YELLOW}Installing curl...${NC}"
    sudo apt-get install -y curl
    echo -e "${GREEN}curl installed: $(curl --version | head -n 1)${NC}"
fi

if command_exists screen; then
    echo -e "${GREEN}screen is already installed.${NC}"
else
    echo -e "${YELLOW}Installing screen...${NC}"
    sudo apt-get install -y screen
    echo -e "${GREEN}screen installed.${NC}"
fi

if command_exists update-ca-certificates; then
    echo -e "${GREEN}ca-certificates is already installed.${NC}"
else
    echo -e "${YELLOW}Installing ca-certificates...${NC}"
    sudo apt-get install -y ca-certificates
    echo -e "${GREEN}ca-certificates installed successfully.${NC}"
fi

echo -e "${CYAN}keyring 디렉토리 만드는 중${NC}"
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo -e "${CYAN}시스템 소스 목록에 추가${NC}"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  
echo -e "${BOLD}${CYAN}Checking for Docker installation...${NC}"
if ! command_exists docker; then
    echo -e "${RED}Docker is not installed. Installing Docker...${NC}"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    echo -e "${CYAN}Docker installed successfully.${NC}"
else
    echo -e "${CYAN}Docker is already installed.${NC}"
fi

echo -e "${CYAN}docker version${NC}"
docker version

echo -e "${CYAN}sudo apt-get update${NC}"
sudo apt-get update

if ! command_exists docker-compose; then
    echo -e "${RED}Docker Compose is not installed. Installing Docker Compose...${NC}"
    # Docker Compose의 최신 버전 다운로드 URL
    sudo curl -L https://github.com/docker/compose/releases/download/$(curl --silent https://api.github.com/repos/docker/compose/releases/latest | jq .name -r)/docker-compose-$(uname -s)-$(uname -m) -o /usr/bin/docker-compose
    sudo chmod 755 /usr/bin/docker-compose
    echo -e "${CYAN}Docker Compose installed successfully.${NC}"
else
    echo -e "${CYAN}Docker Compose is already installed.${NC}"
fi

echo -e "${CYAN}nesa 스크린 실행${NC}"
screen -dms nesa bash -c '
    CYAN="\033[0;36m"
    NC="\033[0m"
    echo -e "${CYAN}지금부터 두 번째 과정 실행, 자세한 건 창매 블로그 참조${NC}"
    bash <(curl -s https://raw.githubusercontent.com/nesaorg/bootstrap/master/bootstrap.sh) && exit
'

node_id=$(cat ~/.nesa/identity/node_id.id)
echo -e "${CYAN}당신의 node id : ${node_id}${NC}"
