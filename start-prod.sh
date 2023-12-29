kubectl create -f ./kube-config/prod/namespace.yml
kubectl create -f ./kube-config/prod/mysql-config.yml

kubectl create -f ./db/auth-service/pvc-prod.yml
kubectl create -f ./db/auth-service/pv-prod.yml
kubectl create -f ./db/auth-service/statefulset-prod.yml
kubectl create -f ./db/auth-service/service-prod.yml

kubectl create -f ./db/member-service/pvc-prod.yml
kubectl create -f ./db/member-service/pv-prod.yml
kubectl create -f ./db/member-service/statefulset-prod.yml
kubectl create -f ./db/member-service/service-prod.yml

kubectl create -f ./db/product-service/pvc-prod.yml
kubectl create -f ./db/product-service/pv-prod.yml
kubectl create -f ./db/product-service/statefulset-prod.yml
kubectl create -f ./db/product-service/service-prod.yml

kubectl create -f ./db/wish-cart-service/pvc-prod.yml
kubectl create -f ./db/wish-cart-service/pv-prod.yml
kubectl create -f ./db/wish-cart-service/statefulset-prod.yml
kubectl create -f ./db/wish-cart-service/service-prod.yml

kubectl create -f ./db/sns-service/pvc-prod.yml
kubectl create -f ./db/sns-service/pv-prod.yml
kubectl create -f ./db/sns-service/statefulset-prod.yml
kubectl create -f ./db/sns-service/service-prod.yml

kubectl create -f ./db/payment-service/pvc-prod.yml
kubectl create -f ./db/payment-service/pv-prod.yml
kubectl create -f ./db/payment-service/statefulset-prod.yml
kubectl create -f ./db/payment-service/service-prod.yml

kubectl create -f ./db/order-service/pvc-prod.yml
kubectl create -f ./db/order-service/pv-prod.yml
kubectl create -f ./db/order-service/statefulset-prod.yml
kubectl create -f ./db/order-service/service-prod.yml

kubectl create -f ./db/promotion-service/pvc-prod.yml
kubectl create -f ./db/promotion-service/pv-prod.yml
kubectl create -f ./db/promotion-service/statefulset-prod.yml
kubectl create -f ./db/promotion-service/service-prod.yml

kubectl create -f ./db/review-service/pvc-prod.yml
kubectl create -f ./db/review-service/pv-prod.yml
kubectl create -f ./db/review-service/statefulset-prod.yml
kubectl create -f ./db/review-service/service-prod.yml

kubectl create -f ./db/notification-service/pvc-prod.yml
kubectl create -f ./db/notification-service/pv-prod.yml
kubectl create -f ./db/notification-service/statefulset-prod.yml
kubectl create -f ./db/notification-service/service-prod.yml

#kubectl create -f ./kafka/prod/cluster/pv.yml
#kubectl create -f ./kafka/prod/cluster/pvc.yml
#kubectl create -f ./kafka/prod/cluster/deployment.yml
#kubectl create -f ./kafka/prod/cluster/service.yml
#kubectl create -f ./kafka/prod/cluster/connect-deployment.yml
#kubectl create -f ./kafka/prod/cluster/connect-service.yml
kubectl create -f ./kafka/prod/standalone/pv.yml
kubectl create -f ./kafka/prod/standalone/pvc.yml
kubectl create -f ./kafka/prod/standalone/deployment.yml
kubectl create -f ./kafka/prod/standalone/service.yml
#kubectl create -f ./kafka/prod/standalone/connect-deployment.yml
#kubectl create -f ./kafka/prod/standalone/connect-service.yml

#kubectl create -f ./redis/prod/cluster/pv.yml
#kubectl create -f ./redis/prod/cluster/configmap.yml
#kubectl create -f ./redis/prod/cluster/statefulset.yml
#kubectl create -f ./redis/prod/cluster/service.yml
kubectl create -f ./redis/prod/standalone/pv.yml
kubectl create -f ./redis/prod/standalone/pvc.yml
kubectl create -f ./redis/prod/standalone/deployment.yml
kubectl create -f ./redis/prod/standalone/service.yml

kubectl create -f ./rabbitmq/prod/deployment.yml
kubectl create -f ./rabbitmq/prod/service.yml