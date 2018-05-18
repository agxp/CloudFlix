
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
helm install --name postgres --set postgresUser=postgres,postgresPassword=postgres123,postgresDatabase=videos,metrics.enabled=true,service.type=LoadBalancer stable/postgresql  
```
8. Install pgAdmin
```sh
docker run -p 3000:3000 -e "PGADMIN_DEFAULT_EMAIL=admin@localhost" -e "PGADMIN_DEFAULT_PASSWORD=pgadmin123" -d dpage/pgadmin4
```
9. Get the postgresql service address 
```sh
minikube service postgres-postgresql --url
```
10. Login to pgAdmin, add the Postgres server, and create the database schema using videos_schema.sql
11. Add the incubator repo to helm with 
```
helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com/
```
12. Install Jaeger (with reasonable limits because I don't have infinite RAM)
```sh
# This command will finish quickly but you have to wait ~5 minutes for the three cassandra nodes to initiate. 
# Until then there will be errors in the k8s dashboard.
helm install incubator/jaeger --name jaeger --set cassandra.config.max_heap_size=1024M --set cassandra.config.heap_new_size=256M --set cassandra.resources.requests.memory=2048Mi --set cassandra.resources.requests.cpu=0.4 --set cassandra.resources.limits.memory=2048Mi --set cassandra.resources.limits.cpu=0.4
```
13. cd into each service folder and run 
```sh
# TODO
make build-local && make deploy-local
```