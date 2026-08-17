# Entra ID Bulk Group Automation

A GitHub Actions-based automation project for performing bulk Microsoft
Entra ID group membership operations using Microsoft Graph PowerShell
SDK.

## 1. Project Overview

**Project Name:** `Entra-ID-Bulk-Group-Automation`

The automation allows an operator to select an environment and an
operation from GitHub Actions and process a CSV request.

Supported environments:

-   DEV
-   UAT
-   PRD

Supported operations:

-   Add Users to Group
-   Remove Users from Group
-   Add Devices to Group
-   Remove Devices from Group

The workflow reads request files from a dedicated `csv-upload` branch
and processes them using Microsoft Graph.

## 2. Technology Stack

  -----------------------------------------------------------------------
  Technology                          Purpose
  ----------------------------------- -----------------------------------
  GitHub Actions                      Workflow orchestration and
                                      execution

  Git / GitHub                        Source control and request-file
                                      tracking

  PowerShell 7                        Automation and scripting

  Microsoft Graph PowerShell SDK      Microsoft Graph / Entra ID
                                      operations

  Microsoft Entra ID                  Identity and group management

  Microsoft Graph API                 API layer

  CSV                                 Bulk request input

  Ubuntu GitHub Runner                Execution environment

  GitHub Environment Secrets          Secure authentication credentials
  -----------------------------------------------------------------------

## 3. Programming Language

The primary programming language is **PowerShell 7**.

PowerShell handles:

-   Microsoft Graph authentication
-   CSV processing
-   Input validation
-   User lookup
-   Device lookup
-   Group lookup
-   Membership validation
-   Add/remove operations
-   Logging
-   Execution summaries
-   Git operations
-   Request-file lifecycle management

The GitHub Actions workflow is written in **YAML**.

## 4. Authentication Design

The project uses Microsoft Graph **app-only authentication**.

GitHub Actions obtains:

-   Tenant ID
-   Client ID
-   Client Secret

from GitHub Environment Secrets.

Typical secret names:

``` text
AZURE_TENANT_ID
AZURE_CLIENT_ID
AZURE_CLIENT_SECRET
```

Authentication flow:

``` text
GitHub Actions
      |
      v
GitHub Environment
      |
      +-- Tenant ID
      +-- Client ID
      +-- Client Secret
      |
      v
Microsoft Graph PowerShell SDK
      |
      v
Microsoft Entra ID
```

No interactive user login is required.

## 5. GitHub Environment Design

The workflow supports:

``` text
DEV
UAT
PRD
```

Each environment can have its own:

``` text
AZURE_TENANT_ID
AZURE_CLIENT_ID
AZURE_CLIENT_SECRET
```

This provides environment isolation and allows different credentials to
be used for each environment.

## 6. Microsoft Graph Permissions

The application registration requires appropriate Microsoft Graph
**Application permissions** for the enabled operations.

The project may require permissions such as:

``` text
User.Read.All
Group.Read.All
Group.ReadWrite.All
GroupMember.ReadWrite.All
Device.ReadWrite.All
```

The final permission set should follow the principle of least privilege
and be reviewed against the exact Graph operations used.

Administrator consent is required for application permissions.

## 7. Git Branch Strategy

Automation code and bulk request data are separated.

### `main`

Contains:

-   GitHub Actions workflows
-   PowerShell scripts
-   Modules
-   Documentation

### `csv-upload`

Contains:

-   Bulk CSV request files
-   Pending requests
-   Completed requests
-   Processing/failed folders

Structure:

``` text
main
 |
 +-- .github/workflows/
 +-- scripts/
 +-- modules/
 +-- README.md

csv-upload
 |
 +-- csv/
```

## 8. CSV Folder Structure

``` text
csv-upload
└── csv/
    ├── dev/
    │   ├── pending/
    │   ├── processing/
    │   ├── completed/
    │   └── failed/
    │
    ├── uat/
    │   ├── pending/
    │   ├── processing/
    │   ├── completed/
    │   └── failed/
    │
    └── prd/
        ├── pending/
        ├── processing/
        ├── completed/
        └── failed/
```

The GitHub UI uses:

``` text
DEV
UAT
PRD
```

The Linux filesystem uses:

``` text
dev
uat
prd
```

because Linux paths are case-sensitive.

## 9. Request File Naming

User operations:

``` text
dev-add-users-to-groups.csv
dev-remove-users-from-groups.csv
uat-add-users-to-groups.csv
uat-remove-users-from-groups.csv
prd-add-users-to-groups.csv
prd-remove-users-from-groups.csv
```

Device operations:

``` text
dev-add-devices-to-groups.csv
dev-remove-devices-from-groups.csv
uat-add-devices-to-groups.csv
uat-remove-devices-from-groups.csv
prd-add-devices-to-groups.csv
prd-remove-devices-from-groups.csv
```

The workflow determines the request filename from the selected
environment and operation.

## 10. CSV Format

### User CSV

``` csv
UserEmail,GroupName
john.doe@company.com,Dev-Team
jane.doe@company.com,Dev-Team
```

Required columns:

``` text
UserEmail
GroupName
```

### Device CSV

``` csv
DeviceName,GroupName
LAPTOP001,Dev-Team
LAPTOP002,Dev-Team
```

Required columns:

``` text
DeviceName
GroupName
```

## 11. Workflow

The main GitHub Actions workflow follows this sequence:

``` text
1. Select Environment
        |
2. Select Operation
        |
3. Select Dry Run
        |
4. Checkout automation repository
        |
5. Fetch CSV from csv-upload branch
        |
6. Validate environment
        |
7. Validate operation
        |
8. Determine request filename
        |
9. Validate request file
        |
10. Validate CSV structure
        |
11. Install Graph modules
        |
12. Authenticate to Microsoft Graph
        |
13. Execute requested operation
        |
14. Generate execution summary
        |
15. Move successful request to completed
        |
16. Commit completed request to csv-upload
```

## 12. Workflow Inputs

### Environment

``` text
DEV
UAT
PRD
```

### Operation

``` text
Add Users to Group
Remove Users from Group
Add Devices to Group
Remove Devices from Group
```

### Dry Run

``` text
Yes
No
```

## 13. Dry Run

### Dry Run = Yes

The automation:

-   Validates the request
-   Looks up users/devices/groups
-   Checks membership
-   Reports intended changes
-   Does not modify group membership
-   Leaves the request in `pending`

Example:

``` text
[Dry Run] User [john.doe@company.com] would be added to [Dev-Team].
```

### Dry Run = No

The automation performs the actual Microsoft Graph operation.

A successful actual execution moves the request:

``` text
pending -> completed
```

## 14. Technical Architecture

``` text
                         GitHub
                           |
             +-------------+-------------+
             |                           |
          main branch                csv-upload
             |                           |
             |                           +-- csv/
             |                               |
             |                               +-- dev/
             |                               +-- uat/
             |                               +-- prd/
             |
             +-- GitHub Actions
             |
             +-- PowerShell
                           |
                           v
                    Ubuntu Runner
                           |
                           v
              Microsoft Graph PowerShell
                           |
                           v
                  Microsoft Graph API
                           |
                           v
                  Microsoft Entra ID
                           |
              +------------+------------+
              |            |            |
            Users       Devices       Groups
```

## 15. Operation Architecture

``` text
GitHub Actions
       |
       v
    main.ps1
       |
       +---------------------+
       |                     |
       v                     v
  User Operations      Device Operations
       |                     |
   +---+---+             +---+---+
   |       |             |       |
   v       v             v       v
  Add    Remove         Add    Remove
```

All four operations use the same orchestration, authentication,
validation, logging, and Dry Run framework.

## 16. User Operations

### Add Users to Group

1.  Read `UserEmail`
2.  Read `GroupName`
3.  Find group
4.  Find user
5.  Check existing membership
6.  Add user when required
7.  Support Dry Run
8.  Produce execution results

### Remove Users from Group

1.  Read `UserEmail`
2.  Read `GroupName`
3.  Find group
4.  Find user
5.  Check existing membership
6.  Remove user when required
7.  Support Dry Run
8.  Produce execution results

## 17. Device Operations

### Add Devices to Group

1.  Read `DeviceName`
2.  Read `GroupName`
3.  Find group
4.  Find device
5.  Check existing membership
6.  Add device when required
7.  Support Dry Run
8.  Produce execution results

### Remove Devices from Group

1.  Read `DeviceName`
2.  Read `GroupName`
3.  Find group
4.  Find device
5.  Check existing membership
6.  Remove device when required
7.  Produce execution results

## 18. Validation Design

### Workflow validation

Validates:

-   Environment
-   Operation
-   Dry Run
-   Environment folder
-   Pending folder
-   Expected request file

### CSV validation

Validates:

-   File existence
-   Records
-   Required columns
-   Required values
-   Duplicate records

### Graph validation

Validates:

-   User existence
-   Device existence
-   Group existence
-   Current membership state

## 19. Request Lifecycle

Initial request:

``` text
csv/dev/pending/
└── dev-add-users-to-groups.csv
```

Successful actual execution:

``` text
csv/dev/completed/
└── dev-add-users-to-groups_20260813-013045_run-152.csv
```

The completed filename contains:

``` text
Original filename
+
UTC timestamp
+
GitHub Actions run number
```

This prevents overwriting previous requests and provides an audit trail.

## 20. Failed Request Behavior

If an actual automation run fails, the request remains in:

``` text
csv/dev/pending/
```

This allows investigation and rerunning.

Dry Run requests also remain in `pending`.

## 21. Git-Based Audit Trail

Completed requests are committed back to `csv-upload`.

Example commit:

``` text
Move dev-add-users-to-groups.csv to completed - Run 152
```

This provides:

-   Git history
-   GitHub Actions run number
-   Timestamp in filename
-   Original request filename

## 22. Logging and Job Summary

The workflow uploads execution logs as GitHub Actions artifacts.

The GitHub Job Summary includes information such as:

``` text
Environment
Operation
Input Type
Request File
Dry Run
Triggered By
Run Number
```

## 23. Security Design

Security controls include:

-   Client secrets stored in GitHub Environment Secrets
-   No credentials hard-coded in scripts
-   App-only Graph authentication
-   Environment-specific credentials
-   Explicit GitHub workflow permissions
-   Dedicated CSV branch
-   Dry Run safety mechanism
-   No automatic deletion of failed requests
-   Timestamped completed requests
-   Least-privilege Graph permission approach

For production, GitHub Environment approvals and stronger credential
management should be considered.

## 24. Linux Case Sensitivity

GitHub-hosted runners use Ubuntu Linux.

Therefore:

``` text
DEV != dev
Pending != pending
```

The project standardizes filesystem paths to lowercase:

``` text
dev
uat
prd

pending
processing
completed
failed
```

The workflow converts the selected UI environment to lowercase before
constructing filesystem paths.

## 25. Error Handling

PowerShell scripts use:

``` powershell
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
```

Individual records are processed with error handling so that a bad
record can be reported without unnecessarily stopping valid records.

Execution summaries report:

``` text
Processed
Successful
Skipped
Failed
Duration
```

## 26. Folder Structure

Recommended automation repository:

``` text
Entra-ID-Bulk-Group-Automation/
│
├── .github/
│   └── workflows/
│       └── bulk-group-membership-management.yml
│
├── modules/
│   ├── authentication/
│   │   └── connect-entra.ps1
│   │
│   ├── users/
│   │   └── get-user.ps1
│   │
│   ├── devices/
│   │   └── get-device.ps1
│   │
│   └── groups/
│       └── get-group.ps1
│
├── scripts/
│   ├── main.ps1
│   ├── common.ps1
│   ├── add-users-to-group.ps1
│   ├── remove-users-from-group.ps1
│   ├── add-devices-to-group.ps1
│   └── remove-devices-from-group.ps1
│
├── logs/
│
└── README.md
```

CSV data is maintained separately on the `csv-upload` branch:

``` text
csv-upload/
└── csv/
    ├── dev/
    │   ├── pending/
    │   ├── processing/
    │   ├── completed/
    │   └── failed/
    ├── uat/
    │   ├── pending/
    │   ├── processing/
    │   ├── completed/
    │   └── failed/
    └── prd/
        ├── pending/
        ├── processing/
        ├── completed/
        └── failed/
```

## 27. Example Execution

Operator selects:

``` text
Environment:
DEV

Operation:
Add Users to Group

Dry Run:
No
```

The workflow resolves:

``` text
csv/dev/pending/dev-add-users-to-groups.csv
```

Example:

``` csv
UserEmail,GroupName
john.doe@company.com,Dev-Team
jane.doe@company.com,Dev-Team
```

Example result:

``` text
Processed  : 2
Successful : 1
Skipped    : 1
Failed     : 0
```

Completed request:

``` text
csv/dev/completed/
└── dev-add-users-to-groups_20260813-013045_run-152.csv
```

## 28. Future Enhancements

Planned or possible enhancements:

-   Per-record execution report
-   HTML execution report
-   Email / Teams notifications
-   PRD approval gates
-   Processing-state folder
-   Failed-request lifecycle
-   Request ID generation
-   Enhanced audit logging
-   Pester unit tests
-   PowerShell linting
-   Pull-request validation
-   Scheduled request processing
-   Centralized reporting
-   Azure Key Vault integration
-   Workload identity federation to reduce long-lived client-secret
    usage

## 29. Project Goals

This project demonstrates practical skills in:

-   GitHub Actions
-   PowerShell automation
-   Microsoft Entra ID
-   Microsoft Graph
-   Identity automation
-   App-only authentication
-   CSV bulk processing
-   Environment-based automation
-   Git branching strategy
-   Linux automation
-   Error handling
-   Dry Run safety
-   Auditability
-   DevOps automation

## 30. End-to-End Summary

``` text
Operator
   |
   v
GitHub Actions
   |
   +-- Environment
   +-- Operation
   +-- Dry Run
   |
   v
CSV Request
   |
   v
PowerShell Automation
   |
   v
Microsoft Graph
   |
   v
Microsoft Entra ID
   |
   v
Execution Result
   |
   +-- Successful -> completed
   |
   +-- Failed ----> pending
```

The project provides a controlled, repeatable, auditable approach to
bulk Entra ID group membership management through GitHub Actions and
Microsoft Graph.

