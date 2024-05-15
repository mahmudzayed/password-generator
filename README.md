# README.md

> Author: Zayed Hasnat Mahmud

---

This repository contains Kubernetes deployment approach for a password generator REST API application written 
in Python.

The application is pretty simple. The application generates secure passwords and takes as input parameters in the API request:

- minimum length
- number of special characters in the password
- number of numbers in the password
- number of passwords that must be created.

---

## Tasks

There are 3 tasks for this project and the associated documentation and configurations are stored in this repository.

Refer to below links for the tasks for files stored under the [docs](docs/) folder:

1. [Exercise 1: Kubernetes](docs/exercise-1-kubernetes.md)
2. [Exercise 2: Terraform](docs/exercise-2-terraform.md)
3. [Blue/green deployment testing on Kubernetes](docs/extra-blue-green-deployment.md)

---

## Configuration Files

There are several folders containing application configurations:

- [app](app/) folder contains application source code and Dockerfile for containerising the app.
- [helmchart](helmchart/) folder contains the helm chart related files that can deploy the application in a Kubernetes cluster.
- [terraform](terraform/) folder stores all major configurations that deploys AWS EKS cluster on a custom VPC.
- [kubernetes](kubernetes/) folder contains all manifests related to custom resources, like Nginx ingress controller and AWS Cluster Autoscaler.

---
