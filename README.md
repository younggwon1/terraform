# Terraform

## Terraform 구성

### Use Lockfile
> Terraform 1.10.0 버전부터는 백엔드 저장소로 DynamoDB 없이 use_lockfile = true 설정을 통해 S3 버킷만 사용해서 리소스 상태 파일 .tfstate의 Lock을 관리할 수 있습니다.

---

## Network 구성
> 6.5.1 버전의 terraform-aws-modules/vpc/aws를 사용하여 VPC, Subnet, NAT, Internet Gateway를 구성

### VPC IP CIDR blocks
- VPC : 10.23.0.0/16 (10.23.0.0 ~ 10.23.255.255)

### Subnet IP CIDR blocks
- Public Subnet (Availability Zone A): 10.23.0.0/24 (10.23.0.0 ~ 10.23.0.255)
- Public Subnet (Availability Zone C): 10.23.1.0/24 (10.23.1.0 ~ 10.23.1.255)

- Private Subnet (Availability Zone A): 10.23.32.0/24 (10.23.32.0 ~ 10.23.32.255)
- Private Subnet (Availability Zone C): 10.23.33.0/24 (10.23.33.0 ~ 10.23.33.255)

### NAT Gateway
- 여러 가용 영역에 리소스가 있고 NAT 게이트웨이 하나를 공유하는 경우, NAT 게이트웨이의 가용 영역이 다운되면 다른 가용 영역의 리소스도 인터넷에 액세스할 수 없게 됩니다.
- 따라서 고가용성을 위해 각 가용 영역에 NAT 게이트웨이를 생성하고 리소스가 동일한 가용 영역의 NAT 게이트웨이를 사용하도록 라우팅을 구성합니다.
- 또한, 가용 영역을 교차하여 라우팅되도록 설정하지 않도록 라우팅 테이블을 설정합니다. (가용 영역을 교차로 라우팅되도록 한다면, 비용 이슈가 발생합니다.)

> 각 가용 영역에 NAT Gateway를 생성할 수 있도록 3번째 케이스로 terraform을 작성하였습니다.
~~~
One NAT Gateway per subnet (default behavior)
# - enable_nat_gateway = true
# - single_nat_gateway = false
# - one_nat_gateway_per_az = false
Single NAT Gateway
# - enable_nat_gateway = true
# - single_nat_gateway = true
# - one_nat_gateway_per_az = false
One NAT Gateway per availability zone
# - enable_nat_gateway = true
# - single_nat_gateway = false
# - one_nat_gateway_per_az = true
~~~

### Internet Gateway
> Internet Gateway를 통해 VPC 내의 리소스가 외부 인터넷과 통신할 수 있도록 create_igw = true 설정을 통해 생성합니다.

### Flow Logs
> VPC Flow Log를 선택적으로 활성화할 수 있도록 구성되어 있으며, CloudWatch Logs 및 IAM Role 생성 여부, 집계 간격, 트래픽 타입 등을 변수로 제어합니다.

---

## ACM 구성
> 퍼블릭 호스트 존과 ACM 인증서를 생성하여 ALB 및 기타 서비스에서 사용할 수 있도록 구성합니다.

- Route 53 퍼블릭 Hosted Zone 생성 (`aws_route53_zone.service`)
- 와일드카드 SAN을 포함한 ACM 인증서 발급 (`aws_acm_certificate.alb_certificate`)
- DNS 검증 레코드 자동 생성 및 검증 완료 리소스 (`aws_route53_record.certificate_validation`, `aws_acm_certificate_validation.alb_certificate`)

ACM 모듈의 출력값(예: `acm_certificate_arn`)은 EC2, EKS 등에서 ALB/Listener 구성 시 참조할 수 있도록 Remote State로 읽어 사용합니다.

---

## EC2 구성

### 개요
EC2 모듈은 재사용 가능한 EC2 인스턴스 모듈을 사용하여 여러 팀별 EC2 인스턴스를 생성합니다. 각 인스턴스는 Application Load Balancer(ALB)와 연결되어 있으며, SSL/TLS 종료를 위해 ACM 인증서를 사용합니다.

### 아키텍처
```
Internet
   ↓
Application Load Balancer (Public Subnet)
   ↓ (HTTPS/HTTP)
Security Group (ALB)
   ↓
Target Group
   ↓
EC2 Instance (Private Subnet)
   ↓
Security Group (EC2)
```

### 모듈 구조
```
ec2/
├── main.tf              # 메인 모듈 호출 및 인스턴스 구성
├── variables.tf         # Terraform 및 Provider 설정
├── data.tf              # Remote State 데이터 소스
└── modules/
    └── ec2-instance/
        ├── main.tf      # EC2, ALB, Security Group, IAM 리소스
        ├── variables.tf # 모듈 입력 변수
        └── output.tf    # 모듈 출력 값
```

### 의존성
EC2 모듈은 다음 모듈의 Remote State에 의존합니다.
- **Network 모듈**: VPC ID, Public/Private Subnet IDs
- **ACM 모듈**: SSL/TLS 인증서 ARN

Remote State는 S3 백엔드를 사용하며 다음 경로에서 읽어옵니다.
- Network: `s3://tf-remote-state/ap-northeast-2.network.tfstate`
- ACM: `s3://tf-remote-state/ap-northeast-2.acm.tfstate`

### 생성되는 인스턴스

#### 1. C-Type Instance (Compute Team)
- **인스턴스 타입**: `c5.large` (컴퓨팅 최적화)
- **용도**: 고성능 컴퓨팅 작업
- **서브넷**: Private Subnet (AZ A)
- **Root Volume**: gp3, 64GB
- **EBS Volume**: gp3, 128GB, 3000 IOPS, 125 MB/s throughput

#### 2. M-Type Instance (Backend Team)
- **인스턴스 타입**: `m5.large` (범용)
- **용도**: 일반적인 애플리케이션 서버
- **서브넷**: Private Subnet (AZ C)
- **Root Volume**: gp3, 64GB
- **EBS Volume**: gp3, 128GB, 3000 IOPS, 125 MB/s throughput

#### 3. T-Type Instance (QA Team)
- **인스턴스 타입**: `t3.medium` (버스트 가능)
- **용도**: 테스트 및 개발 환경
- **서브넷**: Private Subnet (AZ A)
- **Root Volume**: gp3, 16GB
- **EBS Volume**: gp3, 32GB, 1000 IOPS, 50 MB/s throughput
- **CPU Credits**: Standard 모드 (버스트 성능 제어)

### EC2 인스턴스 구성

#### AMI
- **AMI**: Amazon Linux 2023 (al2023-ami-*-kernel-6.1-x86_64)
- **아키텍처**: x86_64

#### User Data
인스턴스 시작 시 자동으로 다음 작업이 수행됩니다.
- Nginx 설치 및 자동 시작 설정
- 기본 HTML 페이지 생성 (`/usr/share/nginx/html/index.html`)

#### 보안 설정
- **Public IP**: 비활성화 (Private Subnet 사용)
- **EBS Optimized**: 활성화
- **Termination Protection**: 활성화
- **Monitoring**: 활성화 (CloudWatch)
- **IMDSv2**: 필수 (HTTP tokens required)
- **Metadata Hop Limit**: 1

#### Block Device
| 볼륨 종류                 | 용도      | 기본 동작   | 이유            |
| --------------------- | ------- | ------- | ------------- |
| **root_block_device** | OS      | 삭제됨     | EC2 없으면 의미 없음 |
| **ebs_block_device**  | 사용자 데이터 | 삭제되지 않음 | 데이터 보호(실수 방지) |

**볼륨 암호화**: 모든 EBS 볼륨은 암호화됩니다.

### IAM 역할 및 정책

각 EC2 인스턴스에는 다음 IAM 역할이 연결됩니다.

1. **AmazonSSMManagedInstanceCore**
   - Systems Manager Session Manager를 통한 인스턴스 접근
   - SSM Agent를 통한 원격 관리

2. **CloudWatchAgentServerPolicy**
   - CloudWatch Logs 및 Metrics 전송
   - 인스턴스 모니터링

### Security Groups

#### ALB Security Group
- **인바운드 규칙**:
  - HTTP (80): 모든 IP 허용
  - HTTPS (443): 모든 IP 허용
- **아웃바운드 규칙**: 모든 트래픽 허용
- **위치**: Public Subnet

#### EC2 Security Group
- **인바운드 규칙**:
  - HTTP (80): ALB Security Group에서만 허용
- **아웃바운드 규칙**: 모든 트래픽 허용
- **위치**: Private Subnet

### Application Load Balancer

#### 구성
- **타입**: Application Load Balancer (Internet-facing)
- **서브넷**: Public Subnets (다중 AZ)
- **Deletion Protection**: 활성화

#### 리스너 구성

1. **HTTP Listener (Port 80)**
   - 모든 HTTP 요청을 HTTPS로 리다이렉트 (301)
   - 보안 강화를 위한 자동 리다이렉션

2. **HTTPS Listener (Port 443)**
   - SSL/TLS 종료
   - SSL Policy: `ELBSecurityPolicy-TLS13-1-2-2021-06`
   - ACM 인증서 사용
   - Target Group으로 트래픽 전달

#### Target Groups

각 인스턴스는 두 개의 Target Group에 등록됩니다.

1. **Target Group 80** (HTTP)
   - Health Check: `/` 경로
   - Healthy Threshold: 3
   - Unhealthy Threshold: 2
   - Success Codes: 200-399

### 모듈 변수

#### 필수 변수
- `vpc_id`: VPC ID
- `instance_type`: EC2 인스턴스 타입
- `public_subnet_ids`: Public Subnet ID 리스트
- `private_subnet_id`: Private Subnet ID
- `name_prefix`: 리소스 이름 접두사
- `team`: 팀 이름 (태그용)
- `acm_certificate_arn`: ACM 인증서 ARN
- `root_volume_type`: Root 볼륨 타입
- `root_volume_size`: Root 볼륨 크기 (GB)
- `ebs_volume_type`: EBS 볼륨 타입
- `ebs_volume_size`: EBS 볼륨 크기 (GB)
- `ebs_iops`: EBS IOPS
- `ebs_throughput`: EBS 처리량 (MB/s)

#### 선택 변수
- `extra_tags`: 추가 태그 (기본값: 빈 맵)

### 모듈 출력

각 EC2 인스턴스 모듈은 다음 출력을 제공합니다:

- `instance_id`: EC2 인스턴스 ID
- `instance_arn`: EC2 인스턴스 ARN
- `iam_role_name`: IAM 역할 이름
- `iam_role_arn`: IAM 역할 ARN
- `iam_instance_profile_name`: IAM 인스턴스 프로파일 이름

### 사용 예시

```hcl
module "ec2_custom_instance" {
  source              = "./modules/ec2-instance"
  vpc_id              = "vpc-xxxxxxxxx"
  instance_type       = "t3.small"
  root_volume_type    = "gp3"
  root_volume_size    = 20
  ebs_volume_type     = "gp3"
  ebs_volume_size     = 50
  ebs_iops            = 3000
  ebs_throughput      = 125
  public_subnet_ids   = ["subnet-xxx", "subnet-yyy"]
  private_subnet_id   = "subnet-zzz"
  team                = "Development Team"
  name_prefix         = "dev"
  acm_certificate_arn = "arn:aws:acm:..."
}
```

### 배포 순서

EC2 모듈을 배포하기 전에 다음 순서로 모듈을 배포해야 합니다.

1. **Network 모듈** 배포
2. **ACM 모듈** 배포 (인증서 생성)
3. **EC2 모듈** 배포

---

## EKS 구성

### 개요
- `eks/` 모듈은 `terraform-aws-modules/eks/aws` **v21.10.1**을 사용하여 EKS 클러스터와 Self-managed Node Group, IRSA 기반 Cluster Autoscaler, ALB용 Security Group을 구성합니다.
- VPC 및 Subnet 정보는 Network 모듈의 Remote State에서, 필요 시 ACM 정보는 ACM 모듈의 Remote State에서 참조합니다.

### 클러스터 기본 설정
- **이름/버전**: `var.cluster_name`(기본 `eks`), `var.cluster_version`(기본 `1.34`)
- **엔드포인트 접근 제어**: 퍼블릭/프라이빗 토글(`var.endpoint_public_access`, `var.endpoint_private_access`)
- **애드온**: `vpc-cni`, `kube-proxy`, `coredns` 버전을 `var.cluster_addons`로 관리
- **삭제 보호**: `deletion_protection = true`

### Self-managed Node Group (커스텀 Launch Template + Mixed Instances)
- **Launch Template**: 직접 정의한 `aws_launch_template.eks_worker`를 사용 (`use_custom_launch_template = true`, `$Latest` 버전 고정)
  - IMDSv2 강제(`http_tokens="required"`), GP3 볼륨 암호화, EBS 최적화, 모니터링 활성화
  - User Data로 `/etc/eks/bootstrap.sh <cluster_name>` 실행 + kubelet NodeConfig 적용
- **Mixed Instances Policy**: 비용·가용성 최적화
  - Launch Template 지정 + 인스턴스 타입 override ( `var.node_instance_types` / 가중치 `var.mixed_instances_weights`)
  - 분배 전략: 온디맨드 기본 용량(`var.mixed_instances_on_demand_base_capacity`), 초과분 온디맨드 비율(`var.mixed_instances_on_demand_percentage`), 스팟 전략 `capacity-optimized`, 스팟 풀 수(`var.mixed_instances_spot_pools`), 스팟 상한가(`var.mixed_instances_spot_max_price`, 빈 문자열이면 온디맨드 가격)
- **스케일 설정**: `min_size`, `max_size`, `desired_size`를 ASG 레벨에서 관리
- **AMI 전략**: `var.node_ami_id`가 없으면 AL2023 EKS Optimized AMI 자동 조회(`data.aws_ami.eks_optimized`)
- **태그**: 클러스터 소유/오토스케일러 인식 태그 포함

### IAM 및 IRSA
- **컨트롤 플레인 IAM Role**:
  - `aws_iam_role.eks-master` 및 `AmazonEKSClusterPolicy`, `AmazonEKSServicePolicy` 부여
- **워커 노드 IAM Role**:
  - `aws_iam_role.eks-worker` 에 `AmazonEKSWorkerNodePolicy`, `AmazonEKS_CNI_Policy`, `AmazonEC2ContainerRegistryPowerUser`, `AmazonSSMManagedInstanceCore` 부여
- **Cluster Autoscaler (IRSA)**:
  - `aws_iam_openid_connect_provider.eks` 로 OIDC Provider 생성
  - OIDC `sub`가 `system:serviceaccount:kube-system:cluster-autoscaler-service` 인 서비스 어카운트에만 AssumeRole 허용
  - Auto Scaling / EC2 / EKS 관련 권한을 갖는 전용 정책(`aws_iam_policy.eks-worker-autoscaler`)과 IAM Role(`aws_iam_role.eks-worker-autoscaler`) 구성
  - 태그 조건(`kubernetes.io/cluster/${var.cluster_name}`, `k8s.io/cluster-autoscaler/enabled`) 기반으로 대상 리소스를 제한

### EKS Access Entries (권한 관리)
- `access_entries` 블록을 통해 EKS **Access Management** 기능을 활용:
  - `cluster_admin`: `AmazonEKSClusterAdminPolicy` 부여 (전체 클러스터 관리자)
  - `cluster_viewer`: `AmazonEKSViewPolicy` 부여 (조회 전용)
  - 각각의 `principal_arn`은 `var.cluster_admin_role_arn`, `var.cluster_viewer_role_arn` 변수로 관리

### 태깅 전략
- 기본 태그:
  - `"Resource" = "eks"`
  - Cluster Autoscaler 인식용 태그:
    - `"k8s.io/cluster-autoscaler/enabled" = "true"`
    - `"k8s.io/cluster-autoscaler/${var.cluster_name}" = "true"`
- 추가 태그:
  - `var.additional_cluster_tags` 맵을 `merge()` 로 합쳐, 비용·조직·환경 태그를 환경별로 유연하게 설정 가능
