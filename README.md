# Azure AD Credentials Rotation Script

## Overview
This script automates the process of updating the credentials for an application in Azure Active Directory (Azure AD). Specifically, it creates a new access key (secret) for a registered application, updates the credentials stored in a local file, and securely removes the old key.

## Script Functionality

### Reading Credentials:
- The script accepts a path to a credentials file as an argument.
- It extracts the variables `APP_ID`, `OBJECT_ID`, `KEY_ID`, `CLIENT_SECRET`, and `TENANT_ID` from the credentials file.

### Credentials Verification:
- Checks if all necessary variables are present in the file.
- Sets `AZURE_CLIENT_SECRET` to use the current `CLIENT_SECRET`.

### Authentication:
- Logs into Azure using the current credentials.

### Creating a New Key:
- Generates a new access key for the application using `mgc` (Microsoft Graph CLI).
- Extracts the `secretText` (the new secret) and `keyId` (the identifier of the new key) from the JSON response.

### Updating Credentials:
- Pauses the script for 10 seconds to allow the new credentials to propagate.
- Updates the credentials file with the new `CLIENT_SECRET` and `KEY_ID`.

### Removing the Old Key:
- Deletes the old access key to maintain security.

### Completion:
- Prints a message indicating the script has completed successfully.

## Use Cases
- **Access Key Rotation**: Ideal for situations requiring regular rotation of application access keys to maintain security.
- **Maintenance Automation**: Can be integrated into an automation system to reduce manual workload and minimize the risk of errors when managing multiple applications and their credentials.
- **Credentials Recovery and Update**: Provides a quick method to update credentials if an access key is considered compromised or is about to expire.
- **DevOps and CI/CD**: Useful in DevOps pipelines to ensure that application credentials are always up-to-date and secure before deploying new changes or versions of an application.

## Requirements
- **Dependencies**: The script depends on standard Linux tools like `grep`, `awk`, `sed`, and `mgc` (Microsoft Graph CLI).
- **Credentials File**: A credentials file with the following variables:
  - `APP_ID`: Application ID in Azure AD.
  - `OBJECT_ID`: Object ID of the application in Azure AD.
  - `KEY_ID`: Current access key ID.
  - `CLIENT_SECRET`: Current access key.
  - `TENANT_ID`: Tenant ID in Azure AD.

## Usage
```sh
./update_credentials.sh /path/to/credentials/file