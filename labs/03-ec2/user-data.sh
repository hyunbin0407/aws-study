#!/bin/bash
# EC2 인스턴스 시작 시 "사용자 데이터"로 넣는 초기 설정 스크립트.
# 인스턴스가 처음 부팅될 때 딱 한 번 root 권한으로 실행된다.
# Amazon Linux 2023 AMI 기준.

dnf update -y
dnf install -y httpd

systemctl start httpd
systemctl enable httpd

# Amazon Linux 2023은 기본적으로 IMDSv2(토큰 기반)를 요구하므로, 토큰 없이 바로 조회하면 빈 값이 반환된다.
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone)

cat <<HTML > /var/www/html/index.html
<html>
  <head><title>IAM/EC2 Lab</title></head>
  <body>
    <h1>Hello from EC2!</h1>
    <p>Instance ID: ${INSTANCE_ID}</p>
    <p>Availability Zone: ${AZ}</p>
  </body>
</html>
HTML
