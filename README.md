Azure Hub & Spoke Landing Zone (Terraform)

Business Scenario
A fictional organisation is migrating on-premises infrastructure to Microsoft Azure and requires a secure, scalable and resilient cloud landing zone to host business applications and administration workloads. The organisation requires centralised management, secure administrative access, private connectivity to cloud services, monitoring, backup and recovery capabilities, and automated infrastructure deployment using Infrastructure as Code.

This project demonstrates how these requirements can be implemented using Microsoft Azure, Terraform and GitHub Actions.

Solution Overview
This project implements an enterprise-style Azure Hub & Spoke Landing Zone deployed entirely using Terraform.

Key Components:
Hub & Spoke Virtual Networking
Azure Bastion
Windows Application VM
Linux Management VM
Network Security Groups (NSGs)
Azure Key Vault
Managed Identities
Azure Storage Account
Private Endpoint & Private DNS
Azure Monitor
Log Analytics Workspace
Data Collection Rules (DCRs)
Recovery Services Vault
GitHub Actions CI/CD
Remote Terraform State Backend
Technologies Used

Terraform
Microsoft Azure
GitHub Actions
Microsoft Entra ID
Azure RBAC
Azure Bastion
Azure Key Vault
Azure Monitor
Log Analytics Workspace
Recovery Services Vault
Azure Storage
Private Endpoints
Private DNS Zones
Architecture

Architecture diagram to be added.

Validation Performed:
Bastion RDP access to the Application VM
Bastion SSH access to the Management VM
Private Endpoint and Private DNS validation
Managed Data Disk validation
Virtual Machine recovery testing
GitHub Actions CI/CD deployment validation
Documentation

The repository includes:
Technical Design Documentation
Testing & Validation Documentation
Lessons Learned & Troubleshooting Documentation
Architecture Diagram
Key Learning Outcomes

This project provided hands-on experience with:
Terraform Infrastructure as Code
Azure networking and Hub & Spoke architectures
Azure RBAC and Microsoft Entra ID
Managed Identities and Azure Key Vault
Private Endpoints and Private DNS integration
Azure Monitor and Log Analytics
Azure Backup and Recovery Services Vault
GitHub Actions CI/CD pipelines
Service Principal authentication
Remote Terraform state management
Cloud troubleshooting and operational support