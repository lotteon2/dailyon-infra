kubectl label node dailyon type=App
kubectl label node dailyon size=Large
kubectl label node dailyon-m02 type=App
kubectl label node dailyon-m02 size=Medium
kubectl label node dailyon-m03 type=Util
kubectl label node dailyon-m03 size=Small
kubectl label node dailyon-m04 type=Kafka
kubectl label node dailyon-m05 type=Redis

kubectl create -f ./kube-config/dev/namespace.yml
kubectl create -f ./kube-config/dev/mysql-config.yml

kubectl create -f ./kafka/dev/deployment.yml
kubectl create -f ./kafka/dev/service.yml

kubectl create -f ./rabbitmq/dev/deployment.yml
kubectl create -f ./rabbitmq/dev/service.yml

kubectl create -f ./discovery-service/deployment.yml
kubectl create -f ./discovery-service/service.yml

kubectl create configmap dailyon-config --from-env-file=./config-service/.env -n dev
kubectl create -f ./config-service/deployment.yml
kubectl create -f ./config-service/service.yml

kubectl create -f ./apigateway-service/deployment.yml
kubectl create -f ./apigateway-service/service.yml

kubectl create -f ./auth-service/initdb-config.yml
kubectl create -f ./auth-service/deployment.yml
kubectl create -f ./auth-service/service.yml

kubectl create -f ./member-service/initdb-config.yml
kubectl create -f ./member-service/deployment.yml
kubectl create -f ./member-service/service.yml

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

kubectl create -f ./sns-service/initdb-config.yml
kubectl create -f ./sns-service/deployment.yml
kubectl create -f ./sns-service/service.yml

kubectl create -f ./review-service/initdb-config.yml
kubectl create -f ./review-service/deployment.yml
kubectl create -f ./review-service/service.yml

kubectl create -f ./notification-service/initdb-config.yml
kubectl create -f ./notification-service/deployment.yml
kubectl create -f ./notification-service/service.yml

kubectl create -f ./wish-cart-service/initdb-config.yml
kubectl create -f ./wish-cart-service/deployment.yml
kubectl create -f ./wish-cart-service/service.yml

kubectl create -f ./auction-service/initdb-config.yml
kubectl create -f ./auction-service/deployment.yml
kubectl create -f ./auction-service/service.yml