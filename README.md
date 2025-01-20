# Terraform

## Network 구성
> 5.17.0 버전의 terraform-aws-modules/vpc/aws를 사용하여 VPC, Subnet, NAT, Internet Gateway를 구성

### VPC IP CIDR blocks
- VPC : 10.21.0.0/16 (10.21.0.0 ~ 10.21.255.255)

### Subnet IP CIDR blocks
- Public Subnet (Availability Zone A): 10.21.0.0/24 (10.21.0.0 ~ 10.21.0.255)
- Public Subnet (Availability Zone C): 10.21.1.0/24 (10.21.1.0 ~ 10.21.1.255)

- Private Subnet (Availability Zone A): 10.21.32.0/24 (10.21.32.0 ~ 10.21.32.255)
- Private Subnet (Availability Zone C): 10.21.33.0/24 (10.21.33.0 ~ 10.21.33.255)

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

---

## EKS 구성
> 20.31.6 버전의 terraform-aws-modules/eks/aws를 사용하여 EKS를 구성

### EKS
> Amazon EKS의 관리형 노드는 각각의 Private Subnet에 위치합니다.

### ALB
> Application Load Balancer는 인터넷으로 접근이 가능하며 구성된 Pod로 라우팅합니다.

> Deployment에 구성될 Pod는 [Spring Boot 이미지](https://spring.io/guides/gs/spring-boot-docker)로 제작하였습니다.

사전 작업으로 클러스터에 [AWS Load Balancer Controller](https://github.com/kubernetes-sigs/aws-load-balancer-controller)를 설치합니다.

- Ingress (ALB)
- TargetGroupBinding

Service는 기존 방식대로 ClusterIP로 설정하고, Ingress의 annotation alb.ingress.kubernetes.io/target-type 값을 ip로 두면, TargetGroupBinding가 생성된 것을 볼 수 있습니다. TargetGroupBinding은 AWS LoadBalancer의 Target Group를 관리하는 기능입니다.
~~~
타겟 타입을 ip로 설정할 경우
- service.type: ClusterIP 
- alb.ingress.kubernetes.io/target-type: "ip"
타겟 타입을 instance로 설정할 경우
- service.type: NodePort or LoadBalancer
- alb.ingress.kubernetes.io/target-type: "instance"
~~~

AWS Load Balancer Controller는 ALB를 생성할 때 Security Group도 자동으로 생성하고 관리합니다.

만약 특정 Security Group을 수동으로 정의하거나, 기본 동작을 오버라이드하고 싶다면 다음과 같이 어노테이션을 사용해 지정할 수 있습니다.
~~~
alb.ingress.kubernetes.io/security-groups: <security-group-id-1>,<security-group-id-2>
~~~
