# cloudflix
vision so far:
![my vision so far](https://lh5.googleusercontent.com/pyLNBtKGMFikOiJm-84kRbuMRrPn3fOLfGBjYwx4_k5TzuRiKy7NBeJaNSz1gXu0JBWhdxrI1mriijemw6Ea_jYAByDUil8g3ljpHhy3dBQ_58T-Ljcjz-OW2feBY6wFc6YatBnl=s0)

## How to run
1. Install kubernetes (minikube)
2. run helm init
3. Install minio with 
`helm install --name minio --set persistence.size=100Gi,accessKey=minio,secretKey=minio123 stable/minio`
4. Clone this repository
5. Install protobuf
6. cd into each service folder and run `make build-local && make deploy-local`
