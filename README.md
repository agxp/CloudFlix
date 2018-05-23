
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
git clone --recurse-submodules -j8 https://github.com/agxp/cloudflix.git
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
##### ALTERNATIVELY
```sh
docker cp ./videos_schema.sql <pgadminContainerID>:/videos_schema.sql
docker exec -it <pgadminContainerID> /bin/sh
psql -U postgres -h localhost -d videos -f /videos_schema.sql
```
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

## Progress
Some simple (naive) load-testing for latency
![Load testing](https://lh3.googleusercontent.com/vm0TSr3Ezj-5WHb1QrLxc6o1XpQzGEn9GOKZ1C4q00Gw_YDmfT7YaNsddUt4Gnj3i-d4Wf5nLxNstsvYvz699GJDZUdqyZfflnTeVNHaZVrAWondt9Smr-Qr3bW3CLP6Uk-IItZ0=s0)

Jaeger view:
![Jaeger view](https://lh4.googleusercontent.com/rmslgs7gFze1oSLFdBhfqPcY7dsJ_HiYc3zEecJBttLF35vSjJsFSOtqKihRGzg97UBWrPTUvsBNV4hUBgG7u-d9wDZtfSd7McH7HorMgUOQqV3--X0QYDCTj6J4dqtEbn7pkmyv=s0)

Barebones skeleton UI:
![User interface](https://lh4.googleusercontent.com/LGdN-l5lC-WMlyCJdC1Fd9mNq2pt2ifBkdAHFtYrCcCHeY5bk5FnmIi6q1aEPn3YLU4nBlc6X_4fZDs9CoilAvkU0SuQ_ni1SlFwnUdFj7U8iOMsYG3xc50o0VAgof6w37obwVw7=s0)

Prometheus view:
![Prometheus](https://lh4.googleusercontent.com/K-NkFuy4fTox2LlcdC8v2oPp_RgimFSMqGItj87GmpnIst97B8U2ud4x7Nf8JEuD4HF6vLWvVvjgJIadhx1cBDsOwaqjbHcHep9UoJGuZFirTHT24fWDG6yTXbLfCmdEOfX-wDUz=s0)

Grafana view (still working on it):
![Grafana](https://lh5.googleusercontent.com/xz-ga9TxKQYks4fhDRuhvwcZohxDq5L8Gt6JPrQEIffxz2VEMf6h6Jel9PPVrlCpGDDGO6yWJxUSnIIRmuGmUH9VRdrRMXRu_Gw1sax3_N_m150EZteqlT9bwL7ja3Q82k9w1N1P=s0)