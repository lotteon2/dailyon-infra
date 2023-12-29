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

kafka-topics --bootstrap-server localhost:9092 --create --topic create-member-for-sns
kafka-topics --bootstrap-server localhost:9092 --create --topic update-member-for-sns
```

* 토픽 목록 조회

```shell
kafka-topics --bootstrap-server localhost:9092 --list
```