kubectl create -f ./kube-config/prod/namespace.yml
kubectl create -f ./kube-config/prod/mysql-config.yml

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