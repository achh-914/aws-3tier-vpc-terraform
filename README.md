# AWS 3-Tier Production VPC Architecture with Terraform

![Architecture Diagram](architecture-diagram.png)

## 📌 Project Overview
This project provisions a highly available, secure, and scalable **3-Tier AWS VPC Infrastructure** using **Terraform (Infrastructure as Code)**. The network design strictly adheres to AWS Cloud Best Practices and follows the **Least Privilege Access Control** model.

---

## 🏗️ Architecture Highlights
- **Multi-AZ Redundancy:** Deployed across 2 Availability Zones (`eu-west-1a` and `eu-west-1b`) for high availability and fault tolerance.
- **3-Tier Subnet Segmentation:**
  - **Public Tier:** Houses Internet Gateway and NAT Gateway.
  - **Application Tier (Private):** Isolated subnet for core application workload with egress internet access via NAT Gateway.
  - **Database Tier (Private):** Fully isolated subnet for databases with zero direct internet access.
- **Network Security:** Tier-based Security Groups restricting inbound/outbound communication paths.

---

## 📂 Repository Structure
```text
├── architecture-diagram.png   # Visual architecture layout
├── main.tf                    # Core VPC, Subnets, and Public Route Tables
├── providers.tf               # AWS Provider configurations
├── variables.tf               # Configurable deployment parameters
├── outputs.tf                 # Exported resource identifiers
├── nat.tf                     # EIP, NAT Gateway, and Private Route Tables
├── security.tf                # Tiered Security Groups (Web, App, DB)
└── README.md                  # Project documentation
---

## 🔐 Security Architecture (Security Groups)

| Security Group | Inbound Rules | Outbound Rules | Purpose |
| :--- | :--- | :--- | :--- |
| **Web SG** | HTTP (80) from `0.0.0.0/0` | All Traffic | Frontend / Public Load Balancer |
| **App SG** | Custom Port (8080) from **Web SG** | All Traffic | Application Logic Tier |
| **DB SG** | MySQL (3306) from **App SG** | All Traffic | Private Database Tier |

---

## 🚀 How to Deploy

1. **Clone the Repository:**
   ```bash
   git clone [https://github.com/achh-914/aws-3tier-vpc-terraform.git](https://github.com/achh-914/aws-3tier-vpc-terraform.git)
   cd aws-3tier-vpc-terraform
