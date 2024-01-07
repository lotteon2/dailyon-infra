# dailyon-infra

## 개발(로컬) 환경

### 모두 실행

```shell
sh ./start-local.sh
```

### 모두 종료

```shell
sh ./stop-local.sh
```

## 운영(EKS) 환경

### AWS EKS 환경으로 내 컴퓨터 환경 변경

```shell
aws eks update-kubeconfig --region ap-northeast-2 --name dailyon
```

### Docker Desktop으로 내 컴퓨터 환경 변경

```shell
kubectl config use-context docker-desktop
```

## EFS CSI Driver 설치

```shell
export cluster_name=dailyon
export role_name=AmazonEKS_EFS_CSI_DriverRole
eksctl create iamserviceaccount \
    --name efs-csi-controller-sa \
    --namespace kube-system \
    --cluster $cluster_name \
    --role-name $role_name \
    --role-only \
    --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy \
    --approve

eksctl create iamserviceaccount \
    --name efs-csi-node-sa \
    --namespace kube-system \
    --cluster $cluster_name \
    --role-name $role_name \
    --role-only \
    --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy \
    --approve
TRUST_POLICY=$(aws iam get-role --role-name $role_name --query 'Role.AssumeRolePolicyDocument' | \
    sed -e 's/efs-csi-controller-sa/efs-csi-*/' -e 's/StringEquals/StringLike/')
aws iam update-assume-role-policy --role-name $role_name --policy-document "$TRUST_POLICY"

eksctl utils describe-addon-versions --kubernetes-version 1.27 | grep AddonName

eksctl utils describe-addon-versions --kubernetes-version 1.27 --name aws-efs-csi-driver | grep AddonVersion

eksctl utils describe-addon-versions --kubernetes-version 1.27 --name aws-efs-csi-driver | grep ProductUrl

eksctl create addon --cluster dailyon --name aws-efs-csi-driver --version latest \
    --service-account-role-arn arn:aws:iam::299378788466:role/AmazonEKS_EFS_CSI_DriverRole --force
```

### Metric server 설치

```shell
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

## Redis 가이드

- 클러스터 구성(6개의 Pod이 뜬 후 실행)

```shell
kubectl exec -it redis-cluster-0 -n prod -- redis-cli --cluster create --cluster-replicas 1 $(kubectl get pods -n prod -l app=redis-cluster -o jsonpath='{range.items[*]}{.status.podIP}{":6379 "}{end}')
```

- 클러스터 정보 확인

```shell
kubectl exec -it redis-cluster-0 -n prod -- redis-cli cluster info
```

## Kafka 가이드


- Container 내부 접속

```shell
docker exec -it [CONTAINER_NAME] /bin/bash
```

- 토픽 생성 - 터미널에서 입력

```shell
docker exec kafka1 kafka-topics --create --topic [TOPIC_NAME] --bootstrap-server kafka1:29092
```

- 토픽 전체 조회 - 터미널에서 입력

```shell
docker exec kafka1 kafka-topics --bootstrap-server kafka1:29092 --list
```

- 컨슈머 모드 - 터미널에서 입력

```shell
docker exec -it [CONTAINER_NAME] kafka-console-consumer.sh --topic create-order --bootstrap-server localhost:9092
```

- 프로듀서 모드 - 터미널에서 입력

```shell
docker exec -it [CONTAINER_NAME] kafka-console-producer.sh --topic create-order --broker-list localhost:9092
```

### 운영 환경

* pod 안에서 실행

* 토픽 생성

```shell
kafka-topics --bootstrap-server localhost:9092 --create --topic approve-payment
kafka-topics --bootstrap-server localhost:9092 --create --topic cancel-order
kafka-topics --bootstrap-server localhost:9092 --create --topic create-order
kafka-topics --bootstrap-server localhost:9092 --create --topic create-order-product
kafka-topics --bootstrap-server localhost:9092 --create --topic create-order-use-coupon
kafka-topics --bootstrap-server localhost:9092 --create --topic create-review
kafka-topics --bootstrap-server localhost:9092 --create --topic use-member-points
kafka-topics --bootstrap-server localhost:9092 --create --topic create-refund

kafka-topics --bootstrap-server localhost:9092 --create --topic create-member-for-sns
kafka-topics --bootstrap-server localhost:9092 --create --topic update-member-for-sns
```

* 토픽 목록 조회

```shell
kafka-topics --bootstrap-server localhost:9092 --list
```