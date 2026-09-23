#!/usr/bin/env bash
# 3회차 EC2 실습 - AWS CLI 명령어 모음 (참고용)
#
# 이 파일은 그대로 실행하는 스크립트가 아니라, README.md의 흐름을 CLI로 대신할 때
# 한 줄씩 복사해서 터미널에 붙여넣고 결과를 확인하는 "cheatsheet"입니다.
# 2회차에서 만든 관리자 계정 자격증명(aws configure)이 이미 설정돼 있다는 전제입니다.

REGION="ap-northeast-2"

# ── 1. 키 페어 생성 ──────────────────────────────────────────────────
aws ec2 create-key-pair \
  --key-name iam-lab-ec2-key \
  --query "KeyMaterial" \
  --output text \
  --region "$REGION" > ~/.ssh/iam-lab-ec2-key.pem
chmod 400 ~/.ssh/iam-lab-ec2-key.pem

# ── 2. 기본 VPC ID 확인 (보안 그룹을 만들 대상 VPC) ────────────────────
VPC_ID=$(aws ec2 describe-vpcs \
  --filters "Name=isDefault,Values=true" \
  --query "Vpcs[0].VpcId" --output text --region "$REGION")
echo "VPC_ID=$VPC_ID"

# ── 3. 보안 그룹 생성 ────────────────────────────────────────────────
SG_ID=$(aws ec2 create-security-group \
  --group-name iam-lab-ec2-sg \
  --description "IAM lab EC2 security group" \
  --vpc-id "$VPC_ID" \
  --query "GroupId" --output text --region "$REGION")
echo "SG_ID=$SG_ID"

# 내 공인 IP 확인 후 SSH(22)는 내 IP만 허용
MY_IP=$(curl -s https://checkip.amazonaws.com)
aws ec2 authorize-security-group-ingress \
  --group-id "$SG_ID" \
  --protocol tcp --port 22 --cidr "${MY_IP}/32" \
  --region "$REGION"

# HTTP(80)는 테스트 편의상 전체 허용
aws ec2 authorize-security-group-ingress \
  --group-id "$SG_ID" \
  --protocol tcp --port 80 --cidr "0.0.0.0/0" \
  --region "$REGION"

# ── 4. 최신 Amazon Linux 2023 AMI ID 조회 ──────────────────────────────
AMI_ID=$(aws ssm get-parameter \
  --name /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 \
  --query "Parameter.Value" --output text --region "$REGION")
echo "AMI_ID=$AMI_ID"

# ── 5. 인스턴스 시작 (user-data.sh 포함) ────────────────────────────────
INSTANCE_ID=$(aws ec2 run-instances \
  --image-id "$AMI_ID" \
  --instance-type t2.micro \
  --key-name iam-lab-ec2-key \
  --security-group-ids "$SG_ID" \
  --user-data file://user-data.sh \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=iam-lab-ec2-instance}]' \
  --query "Instances[0].InstanceId" --output text --region "$REGION")
echo "INSTANCE_ID=$INSTANCE_ID"

# ── 6. running 상태가 될 때까지 대기 후 퍼블릭 IP 조회 ───────────────────
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID" --region "$REGION"
PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids "$INSTANCE_ID" \
  --query "Reservations[0].Instances[0].PublicIpAddress" \
  --output text --region "$REGION")
echo "PUBLIC_IP=$PUBLIC_IP"

# ── 7. 웹서버 확인 (User Data가 httpd를 설치했는지) ─────────────────────
curl "http://${PUBLIC_IP}"

# ── 8. SSH 접속 ─────────────────────────────────────────────────────
ssh -i ~/.ssh/iam-lab-ec2-key.pem "ec2-user@${PUBLIC_IP}"

# ── 9. 중지 / 시작 (퍼블릭 IP가 바뀌는지 확인) ───────────────────────────
aws ec2 stop-instances --instance-ids "$INSTANCE_ID" --region "$REGION"
aws ec2 wait instance-stopped --instance-ids "$INSTANCE_ID" --region "$REGION"

aws ec2 start-instances --instance-ids "$INSTANCE_ID" --region "$REGION"
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID" --region "$REGION"
aws ec2 describe-instances --instance-ids "$INSTANCE_ID" \
  --query "Reservations[0].Instances[0].PublicIpAddress" --output text --region "$REGION"

# ── 10. 정리: 인스턴스 종료 ──────────────────────────────────────────
aws ec2 terminate-instances --instance-ids "$INSTANCE_ID" --region "$REGION"
aws ec2 wait instance-terminated --instance-ids "$INSTANCE_ID" --region "$REGION"

# ── 11. 정리: 보안 그룹 / 키 페어 삭제 ────────────────────────────────
aws ec2 delete-security-group --group-id "$SG_ID" --region "$REGION"
aws ec2 delete-key-pair --key-name iam-lab-ec2-key --region "$REGION"
rm ~/.ssh/iam-lab-ec2-key.pem

# ── 12. 혹시 남은 EBS 볼륨이 있는지 확인 ────────────────────────────────
aws ec2 describe-volumes \
  --filters "Name=status,Values=available" \
  --query "Volumes[].[VolumeId,Size]" --output table --region "$REGION"
