# 나의달 · Mea Luna

앱인토스 현재 개발 버전은 **app/** 폴더에 있습니다. 루트의 lib/, android/, ios/ 등은 기존 Flutter 원본입니다.

## 사무실에서 이어하기

Node.js 22 이상과 Git을 설치한 PC에서:

```powershell
git clone https://github.com/Sanghyug/myMoon.git
cd myMoon/app
npm ci
Copy-Item .env.example .env.local
npm run dev
```

기존 복제본이라면 먼저 git pull을 실행하세요. 코드 작업은 app/src에서 합니다.

.env.local에 다음 앱 전용 광고 그룹 ID를 설정하세요. 광고 그룹 ID는 클라이언트 공개 식별자이며 인증 비밀키가 아닙니다. .env.local 자체는 Git에 올리지 않습니다.

```dotenv
VITE_APP_NAME=mea-luna
VITE_REWARDED_AD_GROUP_ID=ait.v2.live.d3ab1b486f9b4adb
VITE_BANNER_AD_GROUP_ID=ait.v2.live.ea5e1ce463474cfe
VITE_COPYRIGHT_OWNER=밤나무랩
```

검증 및 번들 생성:

```powershell
npm test
node tests/rewarded-ad.test.cjs
npm run build:ait
```

생성된 app/mea-luna.ait를 콘솔에 새 버전으로 업로드합니다. 번들은 Git에 포함하지 않습니다.

## 현재 진행 상태

- 리워드 광고 완료 이벤트에서만 운세 열람 권한을 저장합니다.
- 같은 날 같은 생년월일·시간에는 재시청 없이 복원합니다. 이전 무료 열람 기록과 구분합니다.
- 달 관측과 달력 사이에 배너 1개를 연결했습니다.
- 리워드 모의 테스트 3개 및 .ait 빌드 통과. 실제 토스에서 광고 송출·중도 종료·완료·재접속 확인은 필요합니다.
- 콘솔 심사·출시 상태와 핵심 지표 등록 완료 여부는 콘솔에서 확인하세요.
- 앱 내부 정식 이용약관·개인정보처리방침 보완, 공유 진입 링크 추가는 후속 작업입니다.
- 토스 로그인과 유저정보 연동은 현재 사용하지 않습니다.

앱 상세 설명은 app/README.md를 참고하세요. content/는 원본 콘텐츠, content-review/는 문안 개정 자료입니다.
