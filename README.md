# Jenkins Pipeline Lab

A CI/CD pipeline using Jenkins, Terraform, and AWS S3. The pipeline provisions AWS infrastructure automatically on every GitHub push.

---

## Prerequisites

- Docker Desktop (to run Jenkins locally)
- Terraform installed on the Jenkins container
- AWS account with programmatic access (Access Key + Secret)
- GitHub account
- ngrok (for local Jenkins webhook delivery)

---

## Architecture

```
GitHub Push → GitHub Webhook → ngrok → Local Jenkins (Docker) → Terraform → AWS S3
```

---

## Setup Steps

### 1. Run Jenkins in Docker

Run Jenkins locally via Docker Desktop. Jenkins will be accessible at `http://localhost:8080`. Port `50000` is used for agent communication, but not required for this exercise.

### 2. Install Required Jenkins Plugins

Install the following mandatory plugins via **Manage Jenkins → Plugins**:

Mandatory plugins:

- AWS Credentials

- Pipeline: AWS steps

- Terraform

- Snyk

- Pipeline: GCP steps

- Google Cloud Platform SDK::Auth

- Github integration

- Github Authentication

- Pipeline: Github

### 3. Configure AWS Credentials in Jenkins

Go to **Manage Jenkins → Credentials** and add your AWS Access Key and Secret as an `AWS Credentials` type. Set the credential ID to match what is referenced in the Jenkinsfile (`jenkinsTest`).

### 4. Create the S3 Backend Bucket

The Terraform backend requires an S3 bucket to store the state file. This bucket must be created **manually** in AWS before running the pipeline — Terraform cannot create its own backend bucket.

- Create the bucket in the **same region** specified in `1-auth.tf` under the `backend "s3"` block
- Ensure the region in `1-auth.tf` matches the actual bucket region or `terraform init` will fail with a `301` redirect error

### 5. Configure Terraform Files

**`1-auth.tf`** — Defines the Terraform backend (S3 state storage) and AWS provider region.

**`2-main.tf`** — Defines the AWS resources to provision (S3 bucket and objects).

Ensure the `region` in both the `backend "s3"` block and the `provider "aws"` block match your target AWS region.

### 6. Format Terraform Files

Before pushing, always run:

```bash
terraform fmt
```

The pipeline runs `terraform fmt -check` as a gate. If any `.tf` file is not properly formatted, the pipeline will fail with exit code `3`.

### 7. Expose Jenkins with ngrok

Since Jenkins is running locally, GitHub cannot reach it directly. Use ngrok to create a temporary public URL:

```bash
ngrok http 8080
```

ngrok will output a forwarding URL such as:

```
https://abc123.ngrok-free.app -> http://localhost:8080
```

Note: ngrok generates a new URL each restart. Update your GitHub webhook URL accordingly. For a stable setup, host Jenkins on a cloud server (e.g., AWS EC2 with an Elastic IP).

### 8. Configure GitHub Webhook

In your GitHub repository go to **Settings → Webhooks → Add webhook** and set:

- **Payload URL:** `https://your-ngrok-url.ngrok-free.app/github-webhook/`
- **Content type:** `application/json`
- **Trigger:** Just the push event

### 9. Configure Jenkins Build Trigger

In your Jenkins pipeline job go to **Configure → Build Triggers** and enable **GitHub hook trigger for GITScm polling**.

### 10. Create Jenkins Pipeline Job

In Jenkins create a new **Pipeline** job and configure it to pull the `Jenkinsfile` from your GitHub repository using SCM.

---

## Pipeline Stages

| Stage | Description |
|---|---|
| Checkout | Pulls latest code from GitHub |
| Terraform Init | Initializes Terraform and connects to the S3 backend |
| Terraform Validate | Validates the configuration syntax |
| Terraform Format | Checks formatting with `terraform fmt -check` — fails if files are not formatted |
| Terraform Apply | Runs `terraform plan` then `terraform apply` to provision resources |
| Optional Destroy | Prompts user to optionally run `terraform destroy` |

---

## Triggering the Pipeline

Push any change to the `main` branch on GitHub. Jenkins will automatically trigger a new build via the webhook.

---

## Destroying Resources

At the end of each pipeline run, Jenkins will pause at the **Optional Destroy** stage and prompt:

> Do you want to run terraform destroy?

Select **yes** to tear down all provisioned AWS resources, or **no** to leave them in place.
