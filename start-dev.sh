kubectl label node dailyon type=App
kubectl label node dailyon size=Large
kubectl label node dailyon-m02 type=App
kubectl label node dailyon-m02 size=Medium
kubectl label node dailyon-m03 type=Util
kubectl label node dailyon-m03 size=Small
kubectl label node dailyon-m04 type=Kafka
kubectl label node dailyon-m05 type=Redis
kubectl label node dailyon-m06 type=App
kubectl label node dailyon-m06 size=Medium
kubectl label node dailyon-m07 type=App
kubectl label node dailyon-m07 size=Medium

kubectl create -f ./kube-config/dev/namespace.yml
kubectl create -f ./kube-config/dev/mysql-config.yml

kubectl create -f ./kafka/dev/deployment.yml
kubectl create -f ./kafka/dev/service.yml

kubectl create -f ./redis/dev/deployment.yml
kubectl create -f ./redis/dev/service.yml

kubectl create -f ./rabbitmq/dev/deployment.yml
kubectl create -f ./rabbitmq/dev/service.yml

kubectl create -f ./discovery-service/deployment.yml
kubectl create -f ./discovery-service/service.yml

discovery_service_pod_names=$(kubectl get pods -l app="discovery-service" -n "dev" --output=jsonpath='{.items[*].metadata.name}')
for pod_name in $discovery_service_pod_names; do
  attempt=0
  while [[ $attempt -lt 3 ]]; do
    readiness_probe_status=$(kubectl get pod "${pod_name}" -n "dev" --template='{{range .status.conditions}}{{if eq .type "Ready"}}{{.status}}{{end}}{{end}}')

    if [[ "${readiness_probe_status}" == "True" ]]; then
      echo "Readiness probe is healthy for pod ${pod_name} in namespace dev."

      kubectl create configmap dailyon-config --from-env-file=./config-service/.env -n dev
      kubectl create -f ./config-service/deployment.yml
      kubectl create -f ./config-service/service.yml

      break
    else
      echo "Readiness probe is not healthy for pod ${pod_name} in namespace dev. Sleeping for 60 seconds..."
      sleep 60
      ((attempt++))
    fi
  done
done

config_service_pod_names=$(kubectl get pods -l app="config-service" -n "dev" --output=jsonpath='{.items[*].metadata.name}')
for pod_name in $config_service_pod_names; do
  attempt=0
  while [[ $attempt -lt 3 ]]; do
    readiness_probe_status=$(kubectl get pod "${pod_name}" -n "dev" --template='{{range .status.conditions}}{{if eq .type "Ready"}}{{.status}}{{end}}{{end}}')

    if [[ "${readiness_probe_status}" == "True" ]]; then
      echo "Readiness probe is healthy for pod ${pod_name} in namespace dev."
      break
    else
      echo "Readiness probe is not healthy for pod ${pod_name} in namespace dev. Sleeping for 60 seconds..."
      sleep 60
      ((attempt++))
    fi
  done
done

kubectl create -f ./apigateway-service/deployment.yml
kubectl create -f ./apigateway-service/service.yml

kubectl apply -f ./auth-service/initdb-config.yml
kubectl create -f ./auth-service/deployment.yml
kubectl create -f ./auth-service/service.yml

kubectl apply -f ./member-service/initdb-config.yml
kubectl create -f ./member-service/deployment.yml
kubectl create -f ./member-service/service.yml

kubectl apply -f ./payment-service/initdb-config.yml
kubectl create -f ./payment-service/deployment.yml
kubectl create -f ./payment-service/service.yml

kubectl apply -f ./order-service/initdb-config.yml
kubectl create -f ./order-service/deployment.yml
kubectl create -f ./order-service/service.yml

kubectl apply -f ./product-service/initdb-config.yml
kubectl create -f ./product-service/deployment.yml
kubectl create -f ./product-service/service.yml

kubectl apply -f ./promotion-service/initdb-config.yml
kubectl create -f ./promotion-service/deployment.yml
kubectl create -f ./promotion-service/service.yml

kubectl apply -f ./sns-service/initdb-config.yml
kubectl create -f ./sns-service/deployment.yml
kubectl create -f ./sns-service/service.yml

kubectl apply -f ./review-service/initdb-config.yml
kubectl create -f ./review-service/deployment.yml
kubectl create -f ./review-service/service.yml

kubectl apply -f ./notification-service/initdb-config.yml
kubectl create -f ./notification-service/deployment.yml
kubectl create -f ./notification-service/service.yml

kubectl apply -f ./wish-cart-service/initdb-config.yml
kubectl create -f ./wish-cart-service/deployment.yml
kubectl create -f ./wish-cart-service/service.yml

kubectl apply -f ./auction-service/initdb-config.yml
kubectl create -f ./auction-service/deployment.yml
kubectl create -f ./auction-service/service.yml

kubectl apply -f ./search-service/initdb-config.yml
kubectl create -f ./search-service/deployment.yml
kubectl create -f ./search-service/service.yml