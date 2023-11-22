kubectl create -f ./kafka/dev/deployment-zookeeper.yml
kubectl create -f ./kafka/dev/service-zookeeper.yml

while ! kubectl get services zookeeper-service &> /dev/null; do 
  echo "Waiting for zookeeper-service to become available..."
  sleep 5
done

kubectl create -f ./kafka/dev/deployment-kafka.yml
kubectl create -f ./kafka/dev/service-kafka.yml

while ! kubectl get services kafka-service &> /dev/null; do
  echo "Waiting for kafka-service to become available..."
  sleep 5
done

kubectl create -f ./rabbitmq/dev/deployment.yml
kubectl create -f ./rabbitmq/dev/service.yml

while ! kubectl get services rabbitmq-service &> /dev/null; do
  echo "Waiting for rabbitmq-service to become available..."
  sleep 5
done

kubectl create -f ./discovery-service/deployment.yml
kubectl create -f ./discovery-service/service.yml

while ! kubectl get services discovery-service &> /dev/null; do
  echo "Waiting for discovery-service to become available..."
  sleep 5
done

kubectl create configmap dailyon-config --from-env-file=./config-service/.env
kubectl create -f ./config-service/deployment.yml
kubectl create -f ./config-service/service.yml

while ! kubectl get services config-service &> /dev/null; do
  echo "Waiting for config-service to become available..."
  sleep 5
done

kubectl create -f ./apigateway-service/deployment.yml
kubectl create -f ./apigateway-service/service.yml

while ! kubectl get services apigateway-service &> /dev/null; do
  echo "Waiting for apigateway-service to become available..."
  sleep 5
done

kubectl create -f ./kube-config/mysql-config.yml

kubectl create -f ./auction-service/initdb-config.yml
kubectl create -f ./auction-service/deployment.yml
kubectl create -f ./auction-service/service.yml

kubectl create -f ./auth-service/initdb-config.yml
kubectl create -f ./auth-service/deployment.yml
kubectl create -f ./auth-service/service.yml

kubectl create -f ./member-service/initdb-config.yml
kubectl create -f ./member-service/deployment.yml
kubectl create -f ./member-service/service.yml

kubectl create -f ./notification-service/initdb-config.yml
kubectl create -f ./notification-service/deployment.yml
kubectl create -f ./notification-service/service.yml

kubectl create -f ./order-service/initdb-config.yml
kubectl create -f ./order-service/deployment.yml
kubectl create -f ./order-service/service.yml

kubectl create -f ./payment-service/initdb-config.yml
kubectl create -f ./payment-service/deployment.yml
kubectl create -f ./payment-service/service.yml

kubectl create -f ./product-service/initdb-config.yml
kubectl create -f ./product-service/deployment.yml
kubectl create -f ./product-service/service.yml

kubectl create -f ./promotion-service/initdb-config.yml
kubectl create -f ./promotion-service/deployment.yml
kubectl create -f ./promotion-service/service.yml

kubectl create -f ./review-service/initdb-config.yml
kubectl create -f ./review-service/deployment.yml
kubectl create -f ./review-service/service.yml

kubectl create -f ./sns-service/initdb-config.yml
kubectl create -f ./sns-service/deployment.yml
kubectl create -f ./sns-service/service.yml

kubectl create -f ./wish-cart-service/initdb-config.yml
kubectl create -f ./wish-cart-service/deployment.yml
kubectl create -f ./wish-cart-service/service.yml