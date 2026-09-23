# AWS 스터디 노트

AWS를 처음 공부하면서 정리하는 기록입니다. Claude와 대화하며 학습한 내용을 회차별로 정리해 이 저장소에 쌓아갑니다.

## 진행 방식

1. 아래 커리큘럼에서 순서대로(또는 원하는 순서로) 주제를 하나 고릅니다.
2. 해당 주제로 Claude와 Q&A 하며 학습합니다.
3. 학습이 끝나면 `notes/` 폴더에 회차별 정리 노트가 추가되고, 아래 커리큘럼 체크박스에 체크됩니다.

## 커리큘럼 (초보자 추천 순서)

- [x] 1. 클라우드 컴퓨팅 & AWS 개요 (클라우드란, 리전/가용영역/엣지 로케이션, AWS 글로벌 인프라)
- [x] 2. IAM (계정 보안 기초: 루트 계정, 사용자/그룹/역할, 정책, MFA)
- [x] 3. EC2 (컴퓨팅 기초: 인스턴스, AMI, 보안 그룹, 키 페어, 인스턴스 유형)
- [ ] 4. VPC (네트워킹 기초: 서브넷, 라우팅 테이블, 인터넷 게이트웨이, NAT, 보안 그룹 vs NACL)
- [ ] 5. S3 (스토리지: 버킷/객체, 스토리지 클래스, 버전 관리, 정책)
- [ ] 6. RDS & DynamoDB (관계형 DB vs NoSQL, 기본 운영)
- [ ] 7. ELB & Auto Scaling (고가용성, 부하 분산, 확장성)
- [ ] 8. Route 53 (DNS 기초, 라우팅 정책)
- [ ] 9. CloudWatch & CloudTrail (모니터링, 로깅, 알람)
- [ ] 10. Lambda & 서버리스 (Lambda, API Gateway 기초)
- [ ] 11. IaC 맛보기 (CloudFormation 또는 Terraform 개념)
- [ ] 12. 비용 관리 & AWS Well-Architected Framework
- [ ] 13. 자격증 준비 방향 (AWS Certified Cloud Practitioner / Solutions Architect Associate)

> 순서는 AWS 공식 자격증(Cloud Practitioner → Solutions Architect Associate) 학습 흐름과 실무에서 자주 쓰이는 서비스 순서를 참고해 구성했습니다. 필요하면 언제든 순서를 바꾸거나 건너뛰어도 됩니다.

## 폴더 구조

```
notes/
  01-cloud-and-aws-overview.md
  02-iam.md
  ...
labs/
  02-iam/
    README.md          # 콘솔/CLI 단계별 실습 가이드
    policies/*.json     # 실습에 쓰는 IAM 정책 예제
    cli-commands.sh      # AWS CLI 명령어 모음(참고용)
  03-ec2/
    README.md          # 콘솔/CLI 단계별 실습 가이드
    user-data.sh         # 인스턴스 부팅 시 웹서버 자동 설치 스크립트
    cli-commands.sh      # AWS CLI 명령어 모음(참고용)
  ...
```

각 노트는 다음 형식을 따릅니다.

- 학습 일자
- 핵심 개념 요약
- Q&A로 나온 중요 포인트
- 헷갈렸던 부분 / 추가로 찾아볼 것
- 참고 자료

실습이 필요한 회차는 `labs/<회차번호>-<주제>/`에 콘솔/CLI로 직접 따라 할 수 있는 가이드와 예제 파일을 둡니다.

## 회차 기록

| 회차 | 주제 | 날짜 | 노트 | 실습 |
|---|---|---|---|---|
| 1 | 클라우드 컴퓨팅 & AWS 개요 | 2026-09-15 | [notes/01-cloud-and-aws-overview.md](notes/01-cloud-and-aws-overview.md) | - |
| 2 | IAM | 2026-09-17 | [notes/02-iam.md](notes/02-iam.md) | [labs/02-iam/](labs/02-iam/) |
| 3 | EC2 | 2026-09-23 | [notes/03-ec2.md](notes/03-ec2.md) | [labs/03-ec2/](labs/03-ec2/) |
