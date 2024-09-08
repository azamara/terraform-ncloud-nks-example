# Terraform Ncloud NKS Example

An example repository for managing Naver Cloud Platform infrastructure using Terraform. This project demonstrates how to provision and manage Ncloud Kubernetes clusters (NKS).

## Prerequisites

Before you begin, ensure you have met the following requirements:

- **Terraform**: Version `1.0.0` or higher is required.
- **Homebrew** (for macOS users): To install Terraform via Homebrew.

### Install Terraform CLI

#### Using Homebrew (macOS)

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

For other installation methods, visit the [Terraform Downloads](https://www.terraform.io/downloads.html) page.

## Usage

### Setup API Credentials

For security reasons, it is recommended to use API credentials from a **Sub Account** with the [`NCP_INFRA_MANAGER`](https://guide.ncloud-docs.com/docs/server-subaccount-vpc) role instead of the main account's API keys.

1. **Create a Sub Account**:
   - Navigate to the [Ncloud IAM Dashboard](https://console.ncloud.com/iam/dashboard).
   - Create a new Sub Account and assign the `NCP_INFRA_MANAGER` role.

2. **Generate API Keys**:
   - In the Sub Account, generate a new API Access Key and Secret Key.
   - **Keep these credentials secure** and do not share them.

### Create `terraform.tfvars` File

Create a `terraform.tfvars` file with the following content:

```hcl
access_key               = "YOUR_ACCESS_KEY"
secret_key               = "YOUR_SECRET_KEY"
```

**Note**: Replace the placeholder values with your actual configuration values. Ensure that `terraform.tfvars` is **not** committed to version control to protect sensitive information. Recommend to add `*.tfvars` in `.gitignore`


### Initialize Terraform

After configuring the provider, navigate to the root directory of the project and initialize Terraform to install necessary plugins.

```bash
terraform init
```

### Plan Infrastructure

Review the changes that Terraform will make to your infrastructure.

```bash
terraform plan
```

### Apply Infrastructure

Apply the planned changes to provision the infrastructure.

```bash
terraform apply
```

Type `yes` when prompted to confirm the changes.

### Destroy Infrastructure

If you need to remove all resources created by this configuration, use the following command:

```bash
terraform destroy
```

Type `yes` when prompted to confirm the destruction.

## Project Structure

The project is organized into separate directories for better modularity and maintainability.

```
/
├── modules
│   ├── common
│   ├── network
│   └── kubernetes
└── README.md
```

### Description

- **modules/**: Contains reusable Terraform modules for different components
  - **common/**: Login Key
  - **network/**: VPC, subnets, NAT gateways, and networking configurations
  - **kubernetes/**: NKS cluster setup and configurations

## Additional Information

### Storage Performance Recommendations

When configuring CB1 storage on KVM hypervisor, consider the following:

- **CB1 Storage**:
  - **IOPS Performance** varies based on storage size.
  - It is recommended to use a minimum of **200GB** to achieve at least **600 IOPS**.
    - For example, **10GB** provides **100 IOPS**.

Refer to the [Ncloud KVM Storage Specifications](https://guide.ncloud-docs.com/docs/server-spec-vpc#%EC%8A%A4%ED%86%A0%EB%A6%AC%EC%A7%80-%EC%82%AC%EC%96%91) for more details.

## Notes

- **API Credentials Security**:
  - Always use Sub Account API keys with limited permissions for Terraform operations to minimize security risks.
  - Avoid using main account API keys.

- **State Management**:
  - Terraform state files (`terraform.tfstate`) are critical for tracking infrastructure.
  - Use remote state storage (e.g., Ncloud Object Storage, Terraform Cloud) to manage state securely and facilitate team collaboration.

- **Module Reusability**:
  - The project is modularized to promote reusability and maintainability.
  - Customize modules as needed for additional services.

- **Kubernetes Provider Configuration**:
  - The Kubernetes provider is dynamically configured based on the NKS cluster details.
  - Ensure that the NKS cluster is successfully created before attempting to manage Kubernetes resources.

- **Terraform Commands**:
  - **`terraform init`**: Initializes the Terraform working directory and installs necessary plugins.
  - **`terraform plan`**: Generates an execution plan, showing what actions Terraform will take.
  - **`terraform apply`**: Applies the changes required to reach the desired state of the configuration.
  - **`terraform destroy`**: Destroys all resources managed by the Terraform configuration.

## Troubleshooting

### ERROR - `5001183 - You are not using the Cloud Log Analytics service.`

```log
│ Status: 400 Bad Request, Body: {
│   "responseError": {
│     "returnCode": "5001183",
│     "returnMessage": "You are not using the Cloud Log Analytics service."
│   }
│ }
```

- Accept the Terms of Use of [Cloud Log Analytics](https://console.ncloud.com/cla/home)

### ERROR - `5001183 - Subnet CIDR cannot be duplicated within VPC.`

```log
│ Status: 400 Bad Request, Body: {
│   "responseError": {
│     "returnCode": "5001183",
│     "returnMessage": "Subnet CIDR cannot be duplicated within VPC."
│   }
│ }
```

- Retry


## License

This project is licensed under the [MIT License](LICENSE).

