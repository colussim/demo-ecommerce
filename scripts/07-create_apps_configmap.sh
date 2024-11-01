#!/bin/bash

kubectl -n ecommerce cecreate configmap app-config \
  --from-literal=MYSQL_HOST=X.X.X.X \
  --from-literal=MYSQL_DATABASE=mydb \
  --from-literal=MYSQL_USER=app \
  --from-literal=MYSQL_PORT=6450
