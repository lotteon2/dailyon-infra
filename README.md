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