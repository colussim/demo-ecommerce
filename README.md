# Deploying a Simple E-Commerce Application on Kubernetes

Deploying an e-commerce application based on [**ecommerce-platform**](https://github.com/just-a-rookie-2001/ecommerce-platform). This project aims to adapt and deploy an already existing application designed to work with a MySQL InnoDB cluster.

We will configure and customize the deployment of this application to integrate it into our infrastructure. 

This document will guide you through the deployment process, the necessary configurations, and all the steps to ensure optimal functioning of the application.

## Prerequisites

Before deploying **ecommerce-platform**, ensure that you have the following prerequisites:
- A Kubernetes cluster set up and running with loadbalancer service
- A MySQL Innodb cluster installed or a MySQL instance and configured in kubernetes cluster
- kubectl tool  installed
- MySQL client
- Docker or podman installed
- Docker registry account

## Steps

✅ **Step1 :** Create a sample database (mydb) and load data

Run this command:
```bash

:> mysql -u root -h X.X.X.X -p < Database/DB_SCRIPT.sql
:>
```

✅ **Step2 :** Create a new user for database mydb

Run this command:
```bash

:> mysql -u root -h X.X.X.X -p < Database/create_user.sql
:>
```
This sql script creates an app user with a password , modify this script to change the user name and password.


✅ **Step3 :** Test connexion with new user and database access 

Run this command:
```bash

:> mysql -u app -h X.X.X.X -p mydb -e "SHOW TABLES;"

+-------------------+
| Tables_in_mydb    |
+-------------------+
| address           |
| buyer             |
| buyerorder        |
| order_has_product |
| orderreturns      |
| payment           |
| product           |
| review            |
| shoppingcart      |
| supplier          |
| user              |
| user_log          |
| wishlist          |
+-------------------+
:>
```
This sql script creates an app user with a password , modify this script to change the user name and password.


We previously created a Docker image of this application, making some modifications to the code to enable it to connect to our MySQL InnoDB cluster on different ports.

✅ **Step4 :** Created a Docker image of this application. 

Run the **dockerbuild.sh** script; this script builds a Docker image and pushes it to the Docker registry.
Before executing it, edit the script and update the following variables with your values:
```bash

DOCKER_USER="xxxxx" # Docker user in registry
IMAGE_NAME_ECOMMERCEP="ecommercep" # Image name
CMD="podman" # Executable whether you use podman or docker 
 
```

✅ **Step5 :** Application deployment.

**Namespace creation :**
```bash

:> kubectl create ns ecommerce
namespace/ecommerce created
:>

```

Our application will require the following variables to function:

- MYSQL_HOST=Host_instance
- MYSQL_PORT=db_port
- MYSQL_DATABASE=mydb
- MYSQL_USER=YourMySQLUserName
- MYSQL_PASSWORD=YourMySQLUserPassword
	

We will create a Secret for the password (MYSQL_PASSWORD).

**Secret creation:**
```bash

:> kubectl -n ecommerce create secret generic app-secret \
  --from-literal=MYSQL_PASSWORD=YourMySQLUserPassword
secret/app-secret created
:>

```

We will create a ConfigMap for the other variables(MYSQL_HOST,MYSQL_DATABASE,MYSQL_USER ).

**ConfigMAp creation**:
```bash

:> kubectl -n ecommerce cecreate configmap app-config \
  --from-literal=MYSQL_HOST=X.X.X.X \
  --from-literal=MYSQL_DATABASE=mydb \
  --from-literal=MYSQL_USER=app \
  --from-literal=MYSQL_PORT=6450

configmap/app-config created
:>

```

Now that the configuration is complete, we will deploy our e-commerce application using this Kubernetes manifest.Adapt this manifest to your configuration (Docker image, port, etc.) :

**ecommerce.yaml :**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ecommerce
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ecommerce
  template:
    metadata:
      labels:
        app: ecommerce
    spec:
      containers:
      - name: ecommerce
        image: mcolussi/ecommercep:1.0.1
        ports:
        - containerPort: 5000
        env:
        - name: MYSQL_HOST
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: MYSQL_HOST
        - name: MYSQL_PORT
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: MYSQL_PORT     
        - name: MYSQL_DATABASE
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: MYSQL_DATABASE
        - name: MYSQL_USER
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: MYSQL_USER
        - name: MYSQL_PASSWORD
          valueFrom:
            secretKeyRef:
              name: app-secret
              key: MYSQL_PASSWORD
---
apiVersion: v1
kind: Service
metadata:
  name: ecommerce-service
spec:
  type: LoadBalancer
  ports:
  - port: 5001          
    targetPort: 5000  
  selector:
    app: ecommerce 
	
```

To deploy the application, run this command : 
```bash

:> kubectl -n ecommerce apply -f ecommerce.yaml
deployment.apps/ecommerce created
service/ecommerce-service created
:>
 
```

Check if the application is successfully deployed :

```bash

:> kubectl -n ecommerce get all
NAME                             READY   STATUS    RESTARTS   AGE
pod/ecommerce-6f45495686-pwvcc   1/1     Running   0          98s

NAME                        TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)          AGE
service/ecommerce-service   LoadBalancer   10.96.48.98   10.89.0.103   5001:31334/TCP   99s

NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/ecommerce   1/1     1            1           99s

NAME                                   DESIRED   CURRENT   READY   AGE
replicaset.apps/ecommerce-6f45495686   1         1         1       99s
:>
 
```

The application  is up 😀,we can connect to the external address of the service (10.89.0.103) on port 5001:
http://10.89.0.103:5001


![app.png](imgs/app.png)


* * *

## References

 [ecommerce-platform](https://github.com/just-a-rookie-2001/ecommerce-platform)
