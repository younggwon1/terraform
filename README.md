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

