kubectl create -f ./kube-config/prod/namespace.yml
kubectl create -f ./kube-config/prod/mysql-config.yml

kubectl create -f ./kafka/prod/deployment.yml
kubectl create -f ./kafka/prod/service.yml
#kubectl create -f ./kafka/prod/connect-deployment.yml
#kubectl create -f ./kafka/prod/connect-service.yml

kubectl create -f ./redis/prod/pv.yml
kubectl create -f ./redis/prod/configmap.yml
kubectl create -f ./redis/prod/statefulset.yml
kubectl create -f ./redis/prod/service.yml

kubectl create -f ./rabbitmq/prod/deployment.yml
kubectl create -f ./rabbitmq/prod/service.yml