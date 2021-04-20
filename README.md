

<h1 align="center">k8-go-infra</h1>

<p align="center">
    <a href="https://github.com/k8-proxy/go-k8s-infra/actions/workflows/build.yml">
        <img src="https://github.com/k8-proxy/go-k8s-infra/actions/workflows/build.yml/badge.svg"/>
    </a>
	<a href="https://github.com/k8-proxy/go-k8s-infra/pulls">
        <img src="https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat" alt="Contributions welcome">
    </a>
    <a href="https://opensource.org/licenses/Apache-2.0">
        <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" alt="Apache License, Version 2.0">
    </a>
</p>


# go-k8-infra
Go based Kubernetes infrastructure, providing an ICAP based solution to process files through Glasswall CDR engine.

The work here is a continuation and enhancement over: https://github.com/k8-proxy/icap-infrastructure).

## Version v0.x:

### Solution diagram
![Solution Diagram](https://github.com/k8-proxy/go-k8s-infra/raw/main/diagram/go-k8s-infra.png)
### Enhancements
The solution provides the following enhancements:
- Using MinIO instead of local storage for the processing pods.
- Implementing process pods hot reload feature.


### Components
The solution consists of the following components:
- [Service 1](https://github.com/k8-proxy/go-k8s-srv1)
- [Service 2](https://github.com/k8-proxy/go-k8s-srv2)
- [Processing Service.](https://github.com/k8-proxy/go-k8s-process)
- [Controller Service.](https://github.com/k8-proxy/go-k8s-controller)
- Components related to ICAP server, RabbitMQ, transaction logs , Management UI and similar (From here: https://github.com/k8-proxy/icap-infrastructure).


## Setup from scratch

- Install k8s

- Install helm

- Install kubectl

- Deploy icap-server

- Scale the existing adaptation service to 0
```
kubectl -n icap-adaptation scale --replicas=0 deployment/adaptation-service
```

- Export minio tls cert 
```
kubectl -n minio get secret/minio-tls -o "jsonpath={.data['public\.crt']}" | base64 --decode > /tmp/minio-cert.pem
```

- Import to adaptation service as a configmap 
```
kubectl -n icap-adaptation create configmap minio-cert --from-file=/tmp/minio-cert.pem
```

- Create minio credentials secret
```
kubectl create -n icap-adaptation secret generic minio-credentials --from-literal=username='<minio-user>' --from-literal=password='<minio-password>'
```

- Apply helm chart to create the services
```
helm upgrade servicesv2 --install . --namespace icap-adaptation
```

## Setup

- Deploy a vm from an icap-server AMI with minio installed. Example AMI : ami-099a48891215f2699

- Scale the existing adaptation service to 0
```
kubectl -n icap-adaptation scale --replicas=0 deployment/adaptation-service
```

- Export minio tls cert 
```
kubectl -n minio get secret/minio-tls -o "jsonpath={.data['public\.crt']}" | base64 --decode > /tmp/minio-cert.pem
```

- Import to adaptation service as a configmap 
```
kubectl -n icap-adaptation create configmap minio-cert --from-file=/tmp/minio-cert.pem
```

- Create minio credentials secret
```
kubectl create -n icap-adaptation secret generic minio-credentials --from-literal=username='<minio-user>' --from-literal=password='<minio-password>'
```

- Apply helm chart to create the services
```
helm upgrade servicesv2 --install . --namespace icap-adaptation
```

## How to Create AMI
### Workflow

- Create the ami is done by triggering the icap-server(https://github.com/k8-proxy/GW-Releases/actions?query=workflow%3Aicap-server) workflow

- There are 2 main jobs for that workflow:
    - build-ami
        - Configure AWS credentials
        - Setup Packer
        - Build AMI 

    ![build-ami](imgs/build-ami.png)
    
    - deploy-ami
        - Get current instance ID
        - Deploy AMI to dev
        - Run tests on instance
        - Delete instance(s) that fail

    ![deploy-ami](imgs/deploy-ami.png)

### Workflow Requirements
    - branch to use workflow from
    - AWS region(s) where AMI will be created
    - IP of monitoring server


### Workflow Detail
- [YAML File](https://github.com/k8-proxy/GW-Releases/blob/main/.github/workflows/icap-server.yaml) 
- build AMI
    - Configure AWS credentials
    - Setup [Packer](https://github.com/k8-proxy/vmware-scripts/tree/main/packer)
    - Build AMI using Packer 
- deploy AMI
    - Get current instance ID and other instance IDs with the same name as current instance
    - Deploy the instance
    - Run [healthcheck tests](https://github.com/k8-proxy/vmware-scripts/tree/f129ec357284c61206edf36415b1b2ba403bff95/HealthCheck) on the instance
        - if tests are successful for current instance, all previous instances are terminated
        - if tests are failed, current instance is terminated and deleted

### Execution
- Open the link https://github.com/k8-proxy/GW-Releases/actions/workflows/icap-server.yaml
- Click on "Run workflow" as on the screenshot
![Run workflow](imgs/run_workflow.png)
- Once it's completed the AMI will be available in the logs
![Workflow logs](imgs/workflow_logs.png)

## Test

For testing, try to rebuild a file


