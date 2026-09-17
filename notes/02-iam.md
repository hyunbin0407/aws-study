# 2회차: IAM (Identity and Access Management)

- **날짜**: 2026-09-17
- **주제**: IAM 핵심 개념(사용자/그룹/역할/정책), 최소 권한 원칙, MFA, 정책 평가 로직

## 핵심 개념 요약

### IAM이란?

**IAM(Identity and Access Management)**은 "누가 AWS의 무엇에 접근할 수 있는가"를 관리하는 서비스. EC2나 S3처럼 특정 리전에 속한 서비스가 아니라 **글로벌 서비스**라서, 한 번 만든 사용자/정책은 모든 리전에서 동일하게 적용된다. 그리고 IAM 자체는 **무료**다.

### 루트 계정 vs IAM 사용자

| 구분 | 루트 계정 | IAM 사용자 |
|---|---|---|
| 생성 시점 | AWS 가입 시 자동 생성 | 필요할 때 직접 생성 |
| 권한 | 모든 것 가능 (제한 불가) | 부여받은 권한만 가능 |
| 평소 사용 | ❌ 금지 (결제 정보 변경 등 극히 일부 작업 때만) | ✅ 실무/실습에서 항상 이걸 사용 |
| 보안 | MFA 필수 설정 | 마찬가지로 MFA 권장 |

**루트 계정은 로그인 후 바로 MFA를 걸어두고, 그 이후로는 거의 쓰지 않는 것**이 정석이다.

### 사용자(User) / 그룹(Group) / 역할(Role)

| 구분 | 정의 | 비유 |
|---|---|---|
| **User** | 특정 "사람" 또는 "애플리케이션"을 나타내는 고정 자격증명 (아이디/비번, 액세스 키) | 회사 직원 개인 계정 |
| **Group** | User를 묶어놓은 집합. 그룹에 정책을 붙이면 소속된 모든 User에게 적용됨. (그룹 안에 그룹은 못 넣음) | 팀 (개발팀, 운영팀) |
| **Role** | 특정 자격증명이 아니라 "누군가 잠깐 빌려 쓰는 권한 뭉치". 사람보다는 **EC2, Lambda 같은 AWS 서비스**나 **다른 AWS 계정**, **페더레이션 로그인 사용자**에게 부여. 액세스 키 없이 **임시 자격증명(STS)**으로 동작 | 방문증 (그때그때 빌려 쓰고 반납) |

실무 원칙: **사람에게는 그룹으로 묶은 User**, **서비스에게는 Role**을 쓴다. Role은 자격증명을 코드에 하드코딩할 필요가 없어서 훨씬 안전하다.

### 정책(Policy)

정책은 JSON 문서로 "무엇을 허용/거부할지" 정의한다. 핵심 4요소:

| 요소 | 의미 | 예시 |
|---|---|---|
| `Effect` | 허용인지 거부인지 | `Allow` / `Deny` |
| `Action` | 어떤 API 동작인지 | `s3:GetObject`, `ec2:StartInstances` |
| `Resource` | 어떤 리소스 대상인지 (ARN) | `arn:aws:s3:::my-bucket/*` |
| `Condition` | 언제/어떤 조건에서만 적용할지 (선택) | MFA 여부, 태그, IP 대역 등 |

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::my-bucket/*"
    }
  ]
}
```

- **관리형 정책(Managed Policy)**: 독립된 객체로 존재해서 여러 User/Group/Role에 재사용 가능. AWS가 미리 만들어둔 **AWS 관리형**과 직접 만드는 **고객 관리형**이 있음.
- **인라인 정책(Inline Policy)**: 특정 User/Group/Role 하나에 1:1로 종속됨. 재사용 불가. 그 대상이 삭제되면 정책도 같이 사라짐.

### 정책 평가 로직 (누가 이기는가)

1. 기본은 **모두 거부(Implicit Deny)**
2. 어딘가에 **명시적 Allow**가 있으면 → 허용
3. 어딘가에 **명시적 Deny**가 하나라도 있으면 → 무조건 거부 (Allow보다 항상 우선)

> **명시적 Deny > 명시적 Allow > 암묵적 Deny(기본값)**

이 순서 때문에 "MFA 없으면 아무것도 못 하게" 같은 강력한 제한을 Deny 정책 하나로 걸 수 있다.

### 최소 권한 원칙 (Principle of Least Privilege)

"딱 필요한 작업에, 딱 필요한 리소스에 대해서만" 권한을 준다. `*` (모든 리소스/모든 동작) 권한을 습관적으로 주는 것이 실무에서 가장 흔한 보안 실수.

### MFA (Multi-Factor Authentication)

비밀번호(지식) + OTP 앱/보안 키(소유) 두 가지를 요구해서, 비밀번호가 유출돼도 계정을 지킴. 루트 계정은 필수, IAM 사용자도 강력 권장.

## 헷갈렸던 부분 / 추가로 찾아볼 것

- User와 Role의 차이 — "고정 자격증명 vs 임시로 빌려 쓰는 권한"이라는 감을 실습으로 체화
- 정책 평가 로직에서 Deny가 항상 이긴다는 점 — MFA 강제 정책 실습(콘솔 로그인이 아니라 CLI 액세스 키에서 체감됨)으로 직접 확인
- 실습 중 만난 에러/트러블슈팅은 [`labs/02-iam/README.md`](../labs/02-iam/README.md) 맨 아래 "오늘 실습에서 만난 에러 모음" 표에 정리해둠

## 실습

콘솔 + AWS CLI로 직접 해보는 실습은 [`labs/02-iam/README.md`](../labs/02-iam/README.md) 참고.

## 참고 자료

- AWS 공식 문서: [IAM이란 무엇인가요?](https://docs.aws.amazon.com/ko_kr/IAM/latest/UserGuide/introduction.html)
- AWS 공식 문서: [IAM 정책 평가 로직](https://docs.aws.amazon.com/ko_kr/IAM/latest/UserGuide/reference_policies_evaluation-logic.html)
