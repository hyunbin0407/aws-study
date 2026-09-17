# 2회차 실습: IAM 손으로 익히기

목표: IAM User/Group/Role/Policy를 AWS 콘솔과 CLI로 직접 만들어보면서 개념을 체화한다.
비용은 발생하지 않는 범위(IAM 자체는 무료)로 구성했지만, **실습 후 정리(Step 8)까지 꼭 진행**한다.

이 가이드는 실제로 실습을 진행하면서 겪었던 헷갈린 부분·에러까지 반영해서 정리한 버전이다.

## 0. 사전 준비

- [ ] **루트 계정으로 실습하지 않는다.** 루트 계정에는 로그인 후 MFA만 걸어두고, 실습은 아래에서 만들 IAM 사용자로 한다.
- [ ] "관리자 계정"이란 루트가 아니라, **`AdministratorAccess` 정책이 붙어 있는 평소 로그인용 IAM 사용자**를 말한다. 이게 없으면 아래 실습 중간중간 "권한이 없습니다" 에러를 만나게 된다. IAM → 사용자 → 본인 계정 → Permissions 탭에서 미리 확인해두자.
- [ ] 리전은 아무 곳이나 상관없음 (IAM은 글로벌). 콘솔 우측 상단은 서울(`ap-northeast-2`)로 맞춰두면 편함.
- [ ] AWS CLI가 필요하면 설치: `brew install awscli` (macOS) → 설치 확인은 `aws --version`

> **계정 구분 표시**: 각 Step 제목과 하위 항목에 어떤 계정으로 진행하는지 표시했다.
> - 🔧 **관리자 계정** = `AdministratorAccess`가 있는 내 평소 계정
> - 🔍 **iam-lab-user** = 이번 실습에서 만드는, 권한이 제한된 테스트용 사용자
>
> `iam-lab-user`는 `ReadOnlyAccess`(조회 전용)만 갖고 있어서, 리소스를 "만들고 연결하고 등록하는" 쓰기 작업은 전부 실패한다 (MFA 디바이스 등록도 쓰기 작업이라 예외 없음). 헷갈리면 콘솔 오른쪽 상단에 표시되는 로그인 이름을 먼저 확인할 것.

## Step 1. IAM 그룹 만들기 🔧 관리자 계정

1. AWS 콘솔 → IAM → **사용자 그룹** → **그룹 생성**
2. 그룹 이름: `iam-lab-readonly`
3. 그룹에 정책 연결: 검색창에 `ReadOnlyAccess` 입력

   ⚠️ 검색하면 `AmazonS3ReadOnlyAccess`, `AmazonEC2ReadOnlyAccess`, `IAMReadOnlyAccess` 등 서비스별로 정책이 잔뜩 나온다. 그중 **이름이 정확히 `ReadOnlyAccess`인 것 하나만** 체크한다.
   - 정책 유형(Type) 열이 **"직무 기능(Job function)"** 으로 표시된 게 이것
   - 설명에 "Provides read-only access to AWS services and resources"라고 적혀 있음
   - 거의 모든 AWS 서비스의 조회(List/Describe/Get)만 허용하는 통합 정책이다

4. 그룹 생성 완료

> 이 시점에서 "그룹은 사람이 아니라 정책을 담는 그릇"이라는 감을 잡는 게 목적.

## Step 2. IAM 사용자 만들기 🔧 관리자 계정

1. IAM → **사용자** → **사용자 생성**
2. 사용자 이름: `iam-lab-user`
3. "AWS Management Console 액세스 제공" 체크 → 사용자 지정 비밀번호 설정 (다음 로그인 시 재설정 요구는 꺼도 됨, 실습용)
4. 권한 설정 단계에서 **"그룹에 사용자 추가"** 선택 → Step 1에서 만든 `iam-lab-readonly` 선택
5. 생성 완료 후 **로그인 URL / 사용자 이름 / 비밀번호**를 메모해둔다

> **로그인 화면 헷갈리는 포인트**: IAM 사용자 로그인 화면 맨 위 입력란은 그룹 이름이나 사용자 이름이 아니라 **계정 ID(12자리) 또는 계정 별칭(alias)**이다.
>
> | 입력란 | 뭐가 들어가나 |
> |---|---|
> | 계정 ID 또는 별칭 (맨 위) | IAM 대시보드에 나오는 12자리 계정 ID, 또는 직접 설정한 별칭 |
> | IAM 사용자 이름 | `iam-lab-user` |
> | 비밀번호 | Step 2에서 설정한 비밀번호 |
>
> IAM 대시보드에서 "별칭 만들기"로 원하는 이름을 지정하면 `https://별칭.signin.aws.amazon.com/console` 형태의 기억하기 쉬운 로그인 URL이 생긴다.

## Step 3. 새 사용자로 로그인해서 권한 체감하기 🔍 iam-lab-user

1. 시크릿(프라이빗) 브라우저 창을 열고, Step 2에서 메모한 로그인 URL로 `iam-lab-user`로 로그인
2. S3, EC2 콘솔에 들어가서 **목록 조회는 되는지** 확인 (`ReadOnlyAccess`라 조회는 됨)
3. S3에서 새 버킷을 만들어보거나, EC2 인스턴스를 실행해본다 → **"권한이 없습니다. 관리자에게 권한 추가를 요청하세요"** 에러가 뜨는 걸 확인
4. 이 에러 메시지가 바로 "암묵적 Deny(Implicit Deny)"가 실제로 동작하는 모습이다 — 정책에 명시적으로 허용되지 않은 건 기본적으로 전부 막힌다

## Step 4. 최소 권한 커스텀 정책 만들기

[`policies/s3-read-only-single-bucket.json`](policies/s3-read-only-single-bucket.json)을 사용한다.

### 4-1. 테스트용 S3 버킷 생성 🔧 관리자 계정

1. S3 콘솔 → **버킷 만들기**
2. 버킷 유형: **범용 버킷(General purpose bucket)** 선택
   - 디렉터리 버킷(Directory bucket)은 S3 Express One Zone용 특수 목적(단일 AZ, 고성능)이라 이번 실습과 무관 → 고르지 않는다
3. 버킷 이름은 전 세계 유일해야 하므로 `iam-lab-<이니셜>-bucket-<숫자>` 식으로 작성 (예: `iam-lab-hyunbin-bucket-4718`)
4. 나머지 옵션은 전부 기본값 유지 (퍼블릭 액세스 차단 전체 체크, 버전 관리 비활성화, 기본 암호화 SSE-S3) → **버킷 만들기**

### 4-2. 정책 JSON 준비

로컬 파일 `labs/02-iam/policies/s3-read-only-single-bucket.json`에서 `YOUR-BUCKET-NAME`을 실제 버킷 이름으로 바꾼다.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ListSpecificBucketOnly",
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": "arn:aws:s3:::iam-lab-hyunbin-bucket-4718"
    },
    {
      "Sid": "ReadObjectsInSpecificBucketOnly",
      "Effect": "Allow",
      "Action": ["s3:GetObject"],
      "Resource": "arn:aws:s3:::iam-lab-hyunbin-bucket-4718/*"
    }
  ]
}
```

⚠️ 첫 번째 `Resource`는 버킷 자체(끝에 `/*` 없음) — **목록 조회**(`ListBucket`)용. 두 번째는 `/*`가 붙음 — **객체 조회**(`GetObject`)용. 이 둘의 ARN 형태가 다른 이유는 "버킷을 대상으로 하는 동작"과 "버킷 안 객체를 대상으로 하는 동작"이 서로 다른 리소스이기 때문이다.

### 4-3. IAM 정책 생성 🔧 관리자 계정

1. IAM → **정책(Policies)** → **정책 생성(Create policy)**
2. 정책 편집기에서 **JSON** 탭으로 전환 (기본은 "비주얼" 탭)
3. 위에서 버킷 이름 바꾼 JSON 전체를 붙여넣기 → **다음**
4. 정책 이름: `iam-lab-s3-single-bucket-readonly`
5. 설명(Description)은 **선택 사항**이라 비워도 된다.
   - 참고: 이 필드는 콘솔 IME 이슈로 한글 입력이 안 되는 경우가 있다. 굳이 채우려면 영어로: `IAM lab - read-only access to a single bucket`
6. **정책 생성** 클릭

### 4-4. 사용자에게 정책 연결 🔧 관리자 계정

1. IAM → **사용자** → `iam-lab-user` → **권한(Permissions)** 탭 → **권한 추가 → 직접 정책 연결**
2. `iam-lab-s3-single-bucket-readonly` 검색해서 체크 → **권한 추가**

이제 `iam-lab-user`는 **그룹에서 받은 `ReadOnlyAccess`(모든 서비스 조회) + 개인 정책(특정 버킷만 읽기)** 두 정책을 동시에 갖는다. 여러 정책은 합쳐져서(Union) 평가된다.

### 4-5. 확인 🔍 iam-lab-user

시크릿창에서 다시 로그인 → S3 콘솔:
- 방금 만든 버킷은 **열어서 객체까지 조회 가능**
- 다른 버킷은 **목록에는 보이지만**(`ReadOnlyAccess` 덕분), 열어서 객체를 보려 하면 **AccessDenied** (이 정책이 `GetObject`를 그 버킷 하나로만 한정했기 때문)

## Step 5. MFA 강제 정책 실습 (조심해서 진행)

[`policies/require-mfa-to-do-anything.json`](policies/require-mfa-to-do-anything.json)은 "MFA를 등록하지 않으면 자기 MFA 등록 관련 작업 외엔 아무것도 못 하게" 막는, AWS 공식 예제 패턴이다.

⚠️ **주의**: 이 정책은 `iam-lab-user`에만 연결한다. 관리자 계정에 실수로 걸면 스스로 잠길 수 있다.

### 5-1. MFA 디바이스 등록 🔧 관리자 계정 (iam-lab-user가 아님!)

> 처음엔 `iam-lab-user`로 로그인해서 직접 등록을 시도했는데 **"이 작업을 수행하는 데 필요한 권한이 없습니다"** 에러가 났다. 이유: `ReadOnlyAccess`는 조회 전용 정책이라 `iam:CreateVirtualMFADevice`, `iam:EnableMFADevice` 같은 **쓰기 권한이 아예 없기 때문**이다. MFA 등록도 "쓰기 작업"이라는 걸 여기서 체감할 수 있다. 그래서 이 단계는 관리자 계정에서 대신 진행한다 (QR 스캔은 결국 본인 휴대폰 앱으로 하니 어느 계정 화면에서 QR을 보여주든 상관없다).

1. 관리자 계정으로 IAM → **사용자** → `iam-lab-user` 클릭
2. **보안 자격 증명(Security credentials)** 탭 → **MFA 디바이스** → **MFA 디바이스 할당**
3. 이름: `iam-lab-user-mfa` → 유형: **권한 부여 앱(Authenticator app)**
4. QR 코드를 휴대폰 Google Authenticator/Authy로 스캔
5. 앱에 뜨는 코드를 **연속으로 서로 다른 두 번** 입력 → **MFA 추가**

   **"Authentication code for device is not valid" 에러가 나면:**
   - 같은 코드를 두 번 입력했을 가능성 → 코드가 바뀔 때까지(최대 30초) 기다렸다가 두 번째 코드 입력
   - 입력이 느려서 코드가 이미 만료됐을 가능성 → 새로 뜬 코드로 재시도
   - 휴대폰 시간이 안 맞을 가능성 → 설정 → 날짜/시간 → **자동 설정** 켜져 있는지 확인
   - QR 대신 비밀 키를 손으로 옮겨 적었다면 오타 가능성 → QR 재스캔으로 재시도

### 5-2. MFA 강제 정책 생성 & 연결 🔧 관리자 계정

1. IAM → **정책** → **정책 생성** → JSON 탭
2. `labs/02-iam/policies/require-mfa-to-do-anything.json` 내용 그대로 붙여넣기 (버킷 이름처럼 바꿀 값 없음, `${aws:username}`은 로그인한 사용자 이름으로 AWS가 자동 치환)
3. 정책 이름: `iam-lab-require-mfa`
4. IAM → 사용자 → `iam-lab-user` → 권한 탭 → **권한 추가 → 직접 정책 연결** → `iam-lab-require-mfa` 체크 → 추가

### 5-3. 왜 콘솔 로그인에서는 효과가 안 보이는지

MFA 디바이스를 등록해두면, 콘솔 로그인 시 AWS가 **정책과 무관하게 자동으로** 비밀번호 다음에 MFA 코드를 요구한다. 즉 콘솔 로그인만으로는 이 정책이 "막는 효과"를 체감하기 어렵다.

이 정책이 진짜 힘을 발휘하는 곳은 **액세스 키를 쓰는 CLI/API 접근**이다. 액세스 키 자체는 "MFA로 인증됐는지" 정보를 안 갖고 있어서, 이 정책이 붙으면 **일반 장기 액세스 키로는 거의 아무것도 못 하게** 된다.

### 5-4. 액세스 키 발급 🔧 관리자 계정

1. IAM → 사용자 → `iam-lab-user` → 보안 자격 증명 → **액세스 키 만들기**
2. **사용 사례**: **Command Line Interface (CLI)** 선택
3. "장기 자격증명 대신 단기 자격증명(SSO) 권장" 안내가 뜨면 하단 확인 체크박스 체크 → 다음
4. 설명 태그는 비워도 됨 → **액세스 키 만들기**
5. **Secret access key는 이 화면을 벗어나면 다시 못 보므로** `.csv 다운로드`로 꼭 저장

### 5-5. CLI로 실제 차단 확인 🔍 iam-lab-user (터미널)

```bash
# 1) AWS CLI 설치 확인
aws --version

# 2) 방금 발급받은 iam-lab-user 키 등록
aws configure
# AWS Access Key ID [None]: <csv의 Access key ID>
# AWS Secret Access Key [None]: <csv의 Secret access key>
# Default region name [None]: ap-northeast-2
# Default output format [None]: json

# 3) 계정 ID 확인 (다음 단계에 필요)
aws sts get-caller-identity
# 출력의 "Account" 값이 12자리 계정 ID

# 4) MFA 없이 시도 → AccessDenied 확인
aws s3 ls
# An error occurred (AccessDenied) ... 뜨면 정상

# 5) MFA로 인증된 임시 자격증명 발급
#    <계정ID>와 <앱에_뜨는_6자리_코드>를 실제 값으로 바꿔서 실행 (코드는 30초마다 바뀌니 확인 즉시 실행)
aws sts get-session-token \
  --serial-number arn:aws:iam::<계정ID>:mfa/iam-lab-user-mfa \
  --token-code <앱에_뜨는_6자리_코드>

# 6) 출력된 Credentials 값을 환경변수로 등록
export AWS_ACCESS_KEY_ID="ASIAxxxxxxxxxxxxx"
export AWS_SECRET_ACCESS_KEY="..."
export AWS_SESSION_TOKEN="..."

# 7) 다시 시도 → 이번엔 성공
aws s3 ls

# 8) 테스트 끝나면 환경변수 해제 (원래 등록된 장기 키로 복귀)
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
```

4번은 실패, 7번은 성공 — 이 대비가 "명시적 Deny + Condition(`aws:MultiFactorAuthPresent`)"이 실전에서 어떻게 동작하는지 가장 확실하게 보여준다.

> Step 6(원래 계획엔 "AWS CLI로 접근해보기"가 별도 단계였음)은 이 과정에서 이미 다 겪게 되므로 별도로 진행할 필요 없다.

## Step 6. Role 개념 맛보기 (선택) 🔧 관리자 계정

지금까지는 "사람(User)"에게 권한을 준 것이고, 이번엔 "AWS 서비스"가 빌려 쓰는 권한의 구조만 만들어서 확인한다. 실제 EC2를 띄우지 않아도 되며 비용도 없다.

1. IAM → **역할(Roles)** → **역할 생성**
2. **신뢰할 수 있는 엔터티 유형**: **AWS 서비스** 선택
3. **사용 사례**: **EC2** 선택 → 다음
4. **권한 정책** 단계에서 `ReadOnlyAccess` 검색 후 체크 → 다음
5. **역할 이름**: `iam-lab-ec2-role` → **역할 생성**

생성 후:

6. `iam-lab-ec2-role` 클릭 → **신뢰 관계(Trust relationships)** 탭 확인:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "ec2.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

이게 **신뢰 정책(Trust Policy)** — "이 역할은 오직 EC2 서비스만 빌려 쓸 수 있다"(`Principal`이 사람이 아니라 `ec2.amazonaws.com`)는 뜻. `sts:AssumeRole`은 "이 권한을 잠깐 빌린다"는 API.

7. **권한(Permissions)** 탭에는 `ReadOnlyAccess`가 붙어 있는데, 이게 **권한 정책** — "이 역할을 빌리면 뭘 할 수 있는가."

**핵심 정리**: User/Group에는 정책이 한 종류(권한 정책)만 붙지만, Role에는 **신뢰 정책(누가 빌릴 수 있나) + 권한 정책(빌리면 뭘 할 수 있나)**이 항상 같이 붙는다.

## Step 7. 정리 (Clean up) — 꼭 진행 🔧 관리자 계정

의존 관계가 있어서 순서대로 지워야 에러 없이 삭제된다.

1. **`iam-lab-user` 삭제**: IAM → 사용자 → `iam-lab-user` → 삭제 → 사용자 이름 입력해 확인
   → 액세스 키, MFA 디바이스, 그룹 소속, 직접 연결된 정책 연결까지 이 한 번의 삭제로 같이 정리된다 (정책 자체는 안 지워지고 "연결"만 해제됨)
2. **커스텀 정책 삭제**: IAM → 정책 → `iam-lab-s3-single-bucket-readonly`, `iam-lab-require-mfa` 각각 체크 후 삭제 (더 이상 아무 데도 연결 안 된 상태라야 삭제 가능하며, 1번을 먼저 했으면 문제없음)
3. **그룹 삭제**: IAM → 사용자 그룹 → `iam-lab-readonly` 삭제
4. **역할 삭제**: IAM → 역할 → `iam-lab-ec2-role` 삭제
5. **S3 버킷 삭제**: 버킷 안에 파일이 있으면 먼저 **비우기(Empty)** → 버킷 삭제 (버킷 이름 입력해 확인)
6. **로컬 터미널 정리**:
   ```bash
   unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
   ```
   `~/.aws/credentials`에 남아있는 `iam-lab-user` 관련 키도 지워두면 깔끔함 (지워도 어차피 삭제된 키라 동작은 안 하지만 정리 차원)
7. **유지할 것**: 관리자 계정 자체의 MFA는 그대로 유지 (삭제하지 않음)

### 삭제 확인 방법

CLI에 `iam-lab-user`의 (이미 삭제된) 키가 남아있는 상태에서 아무 명령이나 실행하면:
```bash
aws sts get-caller-identity
# An error occurred (InvalidClientTokenId) when calling the GetCallerIdentity operation
```
이 에러가 뜨면 그 액세스 키를 가진 사용자가 AWS에서 실제로 삭제됐다는 확실한 증거다. 나머지(그룹/정책/역할/버킷)는 콘솔 목록에서 육안으로 안 보이는지 확인하면 된다.

## 오늘 실습에서 만난 에러 모음 (빠른 참조)

| 증상 | 원인 | 해결 |
|---|---|---|
| `ReadOnlyAccess` 검색 결과가 너무 많음 | 서비스별 ReadOnly 정책이 다수 존재 | 이름이 정확히 `ReadOnlyAccess` (Job function 타입)인 것 선택 |
| 로그인 상단 필드에 뭘 넣을지 헷갈림 | 그룹 이름과 계정ID/별칭을 혼동 | 상단 = 계정 ID/별칭, 별도 필드 = IAM 사용자 이름 |
| 정책 Description에 한글 입력 안 됨 | 콘솔 필드 IME 이슈 | 선택 필드이므로 비우거나 영어로 대체 |
| `iam-lab-user`로 MFA 등록 시 "권한이 없습니다" | `ReadOnlyAccess`엔 쓰기 권한 없음 (`iam:CreateVirtualMFADevice` 등) | 관리자 계정에서 대신 등록 |
| "Authentication code for device is not valid" | 같은 코드 재입력 / 코드 만료 / 휴대폰 시간 안 맞음 | 새 코드로 재시도, 휴대폰 자동 시간 설정 확인 |
| MFA 강제 정책 연결 후에도 콘솔 로그인이 그대로 됨 | 콘솔은 MFA 디바이스 등록만으로 자동 요구, 정책과 무관 | CLI 액세스 키로 테스트해야 Deny 효과가 보임 |
| 삭제된 사용자의 키로 CLI 호출 시 `InvalidClientTokenId` | 정상 — 사용자가 실제로 삭제됐다는 증거 | 정리 완료 확인 신호로 활용 |
