# cloudflix
vision so far:
![my vision so far](https://lh5.googleusercontent.com/pyLNBtKGMFikOiJm-84kRbuMRrPn3fOLfGBjYwx4_k5TzuRiKy7NBeJaNSz1gXu0JBWhdxrI1mriijemw6Ea_jYAByDUil8g3ljpHhy3dBQ_58T-Ljcjz-OW2feBY6wFc6YatBnl=s0)

## How to run
1. Install kubernetes (minikube)
2. run helm init
3. Install minio with 
`helm install --name minio --set persistence.size=100Gi,accessKey=minio,secretKey=minio123,service.type=LoadBalancer stable/minio`
4. Port forward minio with `kubectl port-forward <name of minio pod> 9000 --namespace default`
5. Login to minio at localhost:9000 and create a bucket named `videos` (or you can do `minikube service minio`)
6. Clone this repository
7. Install protobuf
8. Install PostgreSQL with 
`helm install --name postgres --set postgresUser=postgres,postgresPassword=postgres123,postgresDatabase=videos,metrics.enabled=true,service.type=LoadBalancer stable/postgresql
`
9. Install pgAdmin with `docker run -p 3000:3000 \
                         -e "PGADMIN_DEFAULT_EMAIL=admin@localhost" \
                         -e "PGADMIN_DEFAULT_PASSWORD=pgadmin123" \
                         -d dpage/pgadmin4
` 
10. Get the postgresql service address with `minikube service postgres-postgresql --url`
11. Go to localhost:3000, login, add the postgres server, and create the database schema using videos_schema.sql
11. cd into each service folder and run `make build-local && make deploy-local`
