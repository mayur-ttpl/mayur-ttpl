## Overview

This project involves migrating microservices hosted on EC2 instances to an EKS (Elastic Kubernetes Service) cluster. The migration process includes setting up an EKS cluster using CloudFormation and the AWS Management Console, configuring a jumpbox for secure access, implementing AWS ALB Ingress Controller, testing microservices, setting up path-based routing, ensuring seamless deployment to both development and production environments, and setting up a CI/CD pipeline using Jenkins.

## Objectives

- Plan the migration process
- Set up an EKS cluster using CloudFormation and the console
- Set up a jumpbox to access the API server with kubectl
- Configure AWS ALB Ingress Controller and ingress objects
- Connect to the cluster and test images using deployment objects
- Implement path-based routing in ingress to access microservices
- Test the functionality of microservices
- Set up secrets and configmaps
- Configure Horizontal Pod Autoscaler (HPA) for high-load microservices
- Update the development environment with EKS and shut down the old server
- Replicate the setup for the production environment
- Set up a CI/CD deployment pipeline using Jenkins

## Steps and Implementation

### 1. Setup Plan

Before beginning the migration, a detailed plan was created to ensure a smooth transition. This plan included timelines, resource allocation, risk assessment, and a rollback strategy.

### 2. Setting Up the EKS Cluster

The EKS cluster was set up using CloudFormation templates and the AWS Management Console to ensure it was in the same network as the RDS instance.

**Steps:**
- Create CloudFormation templates for the EKS cluster.
- Deploy the CloudFormation stack to create the EKS cluster.
- Perform additional configurations using the AWS Management Console.

### 3. Setting Up a Jumpbox

A jumpbox was set up to securely connect to the EKS API server using kubectl.

**Steps:**
- Launch a new EC2 instance to serve as the jumpbox.
- Install kubectl and configure it to access the EKS cluster.
- Secure the jumpbox with appropriate security group settings.

### 4. Configuring AWS ALB Ingress Controller

The AWS ALB Ingress Controller was configured to manage ingress traffic for the EKS cluster.

**Steps:**
- Deploy the AWS ALB Ingress Controller to the EKS cluster.
- Create ingress objects to define routing rules.

### 5. Connecting to the Cluster and Testing Images

Microservices images were tested using deployment objects to ensure they function correctly within the EKS environment.

**Steps:**
- Use kubectl to connect to the EKS cluster.
- Deploy microservices using Kubernetes deployment objects.
- Verify the deployment and functionality of each microservice.

### 6. Setting Up Path-Based Routing

Path-based routing was configured in the ingress objects to direct traffic to the appropriate microservices.

**Steps:**
- Define ingress rules for path-based routing.
- Test the routing to ensure requests are correctly directed to each microservice.

### 7. Testing Microservices

The functionality of each microservice was thoroughly tested to ensure they work as expected in the EKS environment.

**Steps:**
- Perform integration and functional testing for each microservice.
- Address any issues that arise during testing.

### 8. Setting Up Secrets and ConfigMaps

Secrets and ConfigMaps were configured to manage sensitive information and application configuration.

**Steps:**
- Create Kubernetes secrets for sensitive data.
- Create ConfigMaps for application configuration.
- Update deployments to use secrets and ConfigMaps.

### 9. Configuring Horizontal Pod Autoscaler (HPA)

HPA was set up for microservices that experience high load to ensure they can scale automatically.

**Steps:**
- Define HPA rules for high-load microservices.
- Test the autoscaling functionality to ensure it works as expected.

### 10. Updating the Development Environment

The development environment was updated to use the new EKS setup, and the old EC2-based environment was shut down after successful testing.

**Steps:**
- Migrate the development environment to EKS.
- Perform final testing to ensure everything is working correctly.
- Shut down the old EC2 instances after taking backups.

### 11. Replicating the Setup for Production

The same EKS setup was replicated for the production environment to ensure consistency and reliability.

**Steps:**
- Mirror the development setup in the production environment.
- Apply the same security configurations and ingress rules.
- Validate the production deployment with rigorous testing.

### 12. Setting Up CI/CD Deployment Pipeline Using Jenkins

A CI/CD pipeline was set up using Jenkins to automate the deployment process, ensuring continuous integration and delivery of new code changes.

**Steps:**
- Install and configure Jenkins.
- Create Jenkins pipelines for building and deploying Docker images.
- Integrate Jenkins with the container registry and EKS cluster.
- Set up automated testing and deployment stages in the Jenkins pipeline.

## Conclusion

Migrating microservices from EC2 to an EKS cluster with a well-defined plan and thorough testing ensured a smooth transition and improved scalability, security, and manageability. The project successfully updated both development and production environments to use EKS, providing a robust framework for future deployments.

## Future Enhancements

- Implement monitoring and alerting for the EKS cluster and microservices.
- Explore additional Kubernetes features to enhance application resilience and performance.

