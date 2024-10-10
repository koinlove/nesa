```bash
[ -f "nesa.sh" ] && rm nesa.sh; wget -q https://raw.githubusercontent.com/byonjuk/nesa/main/nesa.sh && chmod +x nesa.sh && ./nesa.sh
```

입력

```bash
screen -S nesa
```
입력

```bash
bash <(curl -s https://raw.githubusercontent.com/nesaorg/bootstrap/master/bootstrap.sh)
```

입력

요구하는 것들 싹 다 입력

1. Wizardy 선택되어 있으면 엔터 클릭

2. Moniker: 자신의 노드 이름 (닉네임) 재량껏 설정

3. Email: 자신의 이메일 입력

4. Referral Code: 그대로 엔터

5. HuggingFace API Key: 노드 세팅 사전작업에서 복사한 값 붙여넣기

6. Private Key: 노드 세팅 사전작업에서 복사한 Leap Wallet 프빗키 붙여넣기

7. Start Node: y 입력

설치 됏으면

```bash
node_id=$(cat ~/.nesa/identity/node_id.id)
echo -e "당신의 node id : ${node_id}"
```

입력

그리고 나오는 님 노드아이디 어디다 복사해 두삼. 끝.
