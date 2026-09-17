#!/usr/bin/env bash
# 2회차 IAM 실습 - AWS CLI 명령어 모음 (참고용)
#
# 이 파일은 그대로 실행하는 스크립트가 아니라, README.md의 Step 5-5를 따라가며
# 한 줄씩 복사해서 터미널에 붙여넣고 결과를 확인하는 "cheatsheet"입니다.
# 사용 전: `aws --version`으로 CLI 설치 여부를 먼저 확인하세요.

# ── 1. iam-lab-user의 액세스 키로 CLI 설정 ─────────────────────────────
# IAM 콘솔에서 발급받은 Access Key ID / Secret Access Key를 입력하게 됩니다.
aws configure
# AWS Access Key ID [None]: <발급받은 키 입력>
# AWS Secret Access Key [None]: <발급받은 시크릿 입력>
# Default region name [None]: ap-northeast-2
# Default output format [None]: json

# ── 2. 내가 지금 어떤 자격증명으로 인식되는지 확인 ──────────────────────
aws sts get-caller-identity
# 출력 예시:
# {
#   "UserId": "AIDAxxxxxxxxxxxxx",
#   "Account": "123456789012",
#   "Arn": "arn:aws:iam::123456789012:user/iam-lab-user"
# }

# ── 3. S3 버킷 목록 조회 (ReadOnlyAccess 그룹 정책 덕분에 성공해야 함) ───
aws s3 ls

# ── 4. 특정 버킷 안의 객체 조회 (Step 4 커스텀 정책 적용 대상 버킷) ──────
aws s3 ls s3://YOUR-BUCKET-NAME

# ── 5. 권한이 없는 동작을 시도해서 AccessDenied 확인 ────────────────────
# 예: 새 버킷을 만들어본다 (ReadOnlyAccess만 있으므로 실패해야 정상)
aws s3 mb s3://iam-lab-should-fail-bucket-$RANDOM
# 예상 출력: An error occurred (AccessDenied) when calling the CreateBucket operation

# ── 6. EC2 인스턴스 목록 조회 (ReadOnlyAccess라 조회는 됨) ──────────────
aws ec2 describe-instances --query "Reservations[].Instances[].[InstanceId,State.Name]" --output table

# ── 7. (Step 5 진행 후) MFA 없이 임시 세션이 필요한 API 호출 시 ─────────
# require-mfa 정책이 걸려 있으면 대부분의 호출이 AccessDenied가 됩니다.
# MFA 코드를 포함해 임시 세션 토큰을 발급받아야 합니다:
aws sts get-session-token \
  --serial-number arn:aws:iam::<ACCOUNT_ID>:mfa/iam-lab-user \
  --token-code <MFA_앱에_뜨는_6자리_코드>
# 반환된 AccessKeyId/SecretAccessKey/SessionToken을 환경변수로 export한 뒤 재시도하면 성공합니다.
# export AWS_ACCESS_KEY_ID=...
# export AWS_SECRET_ACCESS_KEY=...
# export AWS_SESSION_TOKEN=...

# ── 8. 실습 종료 후 로컬 CLI 자격증명도 정리 ────────────────────────────
# ~/.aws/credentials 파일에서 iam-lab-user 관련 키를 지우거나,
# 콘솔에서 액세스 키를 먼저 비활성화 → 삭제하세요.
