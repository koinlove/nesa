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

install_Nesa() {
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

echo -e "${CYAN}남은 작업 하고 오세요${NC}"
}

uninstall_Nesa() {
echo -e "${MAGENTA}Nesa 노드 삭제 명령어를 실행합니다.${NC}"
echo -e "${YELLOW}삭제 전 용량을 확인해 주세요~${NC}"
df -h
sleep 10
echo -e "${MAGENTA}켜져있는 스크린을 삭제합니다.${NC}"
screen -X -S nesa kill

echo -e "${MAGENTA}사용 중인 도커를 멈춥니다.${NC}"
docker stop orchestrator
docker stop docker-watchtower-1
docker stop mongodb
docker stop ipfs_node

echo -e "${MAGENTA}사용 중인 도커를 죽입니다.${NC}"
docker kill orchestrator
docker kill docker-watchtower-1
docker kill mongodb
docker kill ipfs_node

echo -e "${MAGENTA}사용 중인 도커를 삭제합니다.${NC}"
docker rm -f orchestrator
docker rm -f docker-watchtower-1
docker rm -f mongodb
docker rm -f ipfs_node

echo -e "${MAGENTA}사용 중인 도커의 이미지를 삭제합니다.${NC}"
docker rmi ghcr.io/nesaorg/orchestrator:devnet-latest
docker rmi mongodb/mongodb-community-server:6.0-ubi8
docker rmi ipfs/kubo:latest
docker rmi containrrr/watchtower:latest

echo -e "${MAGENTA}사용 중인 도커의 네트워크를 삭제합니다.${NC}"
docker network rm docker_nesa

echo -e "${MAGENTA}nesa가 깔려 있는 디렉토리를 지웁니다. ${NC}"
sudo rm -rf ~/.nesa

echo -e "${MAGENTA}Nesa 노드를 (아마도) 완전히 삭제했습니다~ 용량 비워졌는지 확인 한 번 해주세요~${NC}"
df -h
sleep 5
}

# 메인 메뉴
echo && echo -e "${BOLD}${RED}Nesa 노드 설치 명령어 ${NC} by 코인러브미순
${CYAN}원하는 거 고르시고 실행하시고 그러세효. ${NC}
 ———————————————————————
 ${GREEN} 1. Nesa 노드 설치하기 ${NC}
 ${GREEN} 2. Nesa 노드 삭제하기 ${NC}
 ———————————————————————" && echo

# 사용자 입력 대기
echo -ne "${BOLD}${MAGENTA} 어떤 작업을 수행하고 싶으신가요? 위 항목을 참고해 숫자를 입력해 주세요: ${NC}"
read -e num

case "$num" in
1)
    install_Nesa
    ;;
2)
	uninstall_Nesa
	;;

*)
	echo -e "${BOLD}${RED}명령어 잘못 입력한 듯? 븅신ㅉ;${NC}"
	;;
esac