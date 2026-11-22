# Azure Hub & Spoke Landing Zone (Terraform)

## Overview

This project demonstrates the design and deployment of a secure Microsoft Azure Landing Zone using a Hub & Spoke network architecture deployed entirely through Terraform.

The objective was to provide a secure, scalable and resilient cloud environment capable of hosting business applications and administration workloads whilst incorporating Infrastructure as Code, monitoring, backup, security and deployment automation best practices.

---

## Key Features

- Hub & Spoke Networking
- VNet Peering
- Azure Bastion
- Windows Application Virtual Machine
- Linux Management Virtual Machine
- Network Security Groups (NSGs)
- Azure Key Vault
- Managed Identities
- Azure RBAC
- Azure Storage Account
- Private Endpoints
- Private DNS Zones
- Azure Monitor
- Log Analytics Workspace
- Data Collection Rules (DCRs)
- Recovery Services Vault
- Azure Backup
- GitHub Actions CI/CD
- Remote Terraform State Backend

---

## CICD Architecture Diagram & Environment Architecture


<img width="1536" height="1024" alt="Terraform Azure CI_CD Workflow" src="https://github.com/user-attachments/assets/a1ba64b2-e5aa-4f80-91a5-beedbd8e6afb" />

<img width="1522" height="794" alt="678764005-d90c1e07-bf92-4051-ba1d-19b2e69f26d9" src="https://github.com/user-attachments/assets/089e8a97-8ccf-415a-b0e5-430ddd8e3088" />


---

## Business Requirements

- Secure administration of workloads
- Centralised identity management
- Governance through Azure RBAC
- Monitoring and alerting
- Backup and recovery
- Private access to Azure Storage
- Infrastructure as Code deployment
- Automated deployments through CI/CD

---

## Validation Performed

- Bastion RDP connectivity validation
- Bastion SSH connectivity validation
- Managed data disk validation
- Private Endpoint and Private DNS validation
- Virtual machine recovery validation
- GitHub Actions CI/CD validation

---

## Documentation

- Technical Design Documentation
- Testing & Validation Documentation
- Troubleshooting & Lessons Learned Documentation

---

## Technologies

Microsoft Azure, Terraform, Microsoft Entra ID, Azure RBAC, Azure Bastion, Azure Key Vault, Managed Identities, Azure Storage, Private Endpoints, Private DNS, Azure Monitor, Log Analytics Workspace, Recovery Services Vault, Git, GitHub and GitHub Actions.

---

## Documentation

This repository contains supporting project documentation:

- Technical Documentation
- Testing & Validation
- Lessons Learned
- Phase 2 - Azure Firewall and User Defined Routes

---

## Phase 2 Enhancement

Phase 2 introduced:

- Azure Firewall
- Azure Firewall Policy
- User Defined Routes (UDRs)
- Centralised outbound routing
- Effective Route validation

Workloads within the spoke subnets now forward outbound traffic to the Azure Firewall using a default route (0.0.0.0/0) configured through a shared route table.

Microsoft Azure, Terraform, Microsoft Entra ID, Azure RBAC, Azure Bastion, Azure Key Vault, Managed Identities, Azure Storage, Private Endpoints, Private DNS, Azure Monitor, Log Analytics Workspace, Recovery Services Vault, Git, GitHub and GitHub Actions.