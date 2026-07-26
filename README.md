# Entra ID Bulk Group Automation

## Overview

This project automates Microsoft Entra ID (Azure AD) group membership using GitHub Actions and Microsoft Graph.

The solution is designed to support enterprise Identity and Access Management (IAM) operations by processing users in bulk from an Excel spreadsheet.

---

## Features

- Add users to Entra ID groups
- Remove users from Entra ID groups
- Bulk processing from Excel
- Support for DEV, UAT and PROD environments
- Validation mode (Dry Run)
- Execution reports
- Logging
- GitHub Actions automation

---

## Technology Stack

| Technology | Purpose |
|------------|---------|
| GitHub Actions | Workflow Automation |
| Azure CLI | Authentication & Graph API |
| Microsoft Graph | User & Group Management |
| Python | Excel Processing & Reporting |
| Bash | Automation Scripts |
| openpyxl | Read & Write Excel |

---

## Project Structure

```
Entra-ID-Bulk-Group-Automation
│
├── .github/
├── config/
├── docs/
├── input/
├── logs/
├── reports/
├── scripts/
│
├── README.md
├── .gitignore
└── requirements.txt
```

---

## Learning Objectives

This repository demonstrates:

- GitHub Actions
- Azure App Registration
- Service Principals
- Microsoft Graph
- Bash Scripting
- Python Automation
- Enterprise Repository Design
- Azure IAM Automation

---

## Roadmap

- [ ] Repository Foundation
- [ ] Azure Authentication
- [ ] Read Excel
- [ ] Find User
- [ ] Find Group
- [ ] Add User
- [ ] Remove User
- [ ] Bulk Processing
- [ ] Reporting
- [ ] DEV/UAT/PROD Support
- [ ] Production Release