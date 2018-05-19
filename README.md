
# CloudFlix  
vision so far:  
![my vision so far](https://lh5.googleusercontent.com/pyLNBtKGMFikOiJm-84kRbuMRrPn3fOLfGBjYwx4_k5TzuRiKy7NBeJaNSz1gXu0JBWhdxrI1mriijemw6Ea_jYAByDUil8g3ljpHhy3dBQ_58T-Ljcjz-OW2feBY6wFc6YatBnl=s0)  
  
# Running  
1. Install Kubernetes (minikube):  
```sh  
# TODO
```  
2. Init helm:  
```sh  
helm init 
```  
3. Install Minio:   
```sh
helm install --name minio --set persistence.size=100Gi,accessKey=minio,secretKey=minio123,service.type=LoadBalancer stable/minio  
```  
4. Login to Minio at the url and create a bucket named `videos`. 
```sh
minikube service minio --url
```
5. Clone this repository
```sh
cd $GOPATH/src/github.com # mkdir github.com if needed
mkdir agxp && cd agxp
git clone https://github.com/agxp/cloudflix.git
```
6. Install protobuf
```sh
# TODO
```
7. Install PostgreSQL
```sh
helm install --name postgres --set postgresUser=postgres,postgresPassword=postgres123,postgresDatabase=videos,metrics.enabled=true stable/postgresql  
```
8. Install pgAdmin
```sh
docker run --net="host" -e "PGADMIN_DEFAULT_EMAIL=admin@localhost" -e "PGADMIN_DEFAULT_PASSWORD=pgadmin123" -d dpage/pgadmin4
```
9. Forward the postgres port 
```sh
kubectl port-forward <postgres-pod-name> 5432
```
10. Add db schema
- Login to pgAdmin (localhost:80)
- add the Postgres server (localhost:5432)
- create the database schema using videos_schema.sql
11. Add the incubator repo to helm with 
```
helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com/
```
12. Install Jaeger
```sh
kubectl create -f https://raw.githubusercontent.com/jaegertracing/jaeger-kubernetes/master/all-in-one/jaeger-all-in-one-template.yml
```
13. Fix the serviceaccount settings (warning: this is insecure)
```sh
kubectl create clusterrolebinding add-on-cluster-admin --clusterrole=cluster-admin --serviceaccount=default:default
```
14. Install Prometheus
```sh
kubectl create -f https://raw.githubusercontent.com/coreos/prometheus-operator/master/bundle.yaml
```
Wait till pods are green (~1 minute)
```
kubectl create -f https://raw.githubusercontent.com/objectiser/opentracing-prometheus-example/master/prometheus-kubernetes.yml
```
15. Install Grafana
```
helm install --name grafana --set service.type=LoadBalancer stable/grafana
```
- Get the Prometheus URL with `minikube service prometheus --url`
- Port-forward Grafana
```
kubectl port-forward <grafana-pod-name> 3000:3000
```
- Login to Grafana with user admin and password 
```sh
kubectl exec <grafana-pod-name> -- printenv | grep PASSWORD
```
- Add the prometheus URL as a new data source
- Create a dashboard using `http://raw.githubusercontent.com/objectiser/opentracing-prometheus-example/master/simple/GrafanaDashboard.json`
14. cd into each service folder and run 
```sh
# TODO
make build-local && make deploy-local
```


![Jaeger view](https://lh4.googleusercontent.com/Jt6-KFhyQ2eimGyenLVH3I3KpiikEMKbhBtb_Tjub1zA49rKyXYS6nS3LjRzlZ2P1k2fse1Hx4V7-VkSJOmwlIcq5PiMEtntxobrgy9y52WLDTnZLAPGMdqT7KhT9kUw86vYD1c3=s0)

