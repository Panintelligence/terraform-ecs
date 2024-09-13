
# Instructions

## Prepare dashboard prep
This bash script prepares the AWS Lambda to be deployed in your AWS environment.
```
./build_lambda.py
```

## Navigate to terraform directory
```
cd terraform
```
## Prepare the enviroment variables
Fill in the values that you wish to change and replace the default values
```
source .env
```

## Initialise terraform
You will need an AWS S3 bucket to save your Terraform state file.
```
terraform init -backend-config="bucket=<<bucketname>>" -backend-config="region=" -backend-config="key=<<name>>/terraform.tfstate"
```

## Create Plan
```
terraform plan -out=plan \
-var="region=${REGION}" \
-var="hosted_zone_edit_role_arn=${HOSTED_ZONE_EDIT_ROLE_ARN}" \
-var="hosted_zone_id=${HOSTED_ZONE_ID}" \
-var="dashboard_db_password=${DASHBOARD_DB_PASSWORD}" \
-var="dashboard_db_username=${DASHBOARD_DB_USERNAME}" \
-var="licence_key=${LICENCE_KEY}" \
-var="certificate_arn=${CERTIFICATE_ARN}" \
-var="pi_proxy_host=${PI_PROXY_HOST}" \
-var="renderer_dashboard_url=${RENDERER_DASHBOARD_URL}" \
-var="docker_hub_credentials={\"username\":\"${GITHUB_CREDENTIALS_USERNAME}\",\"password\":\"${GITHUB_CREDENTIALS_PASSWORD}\"}" \
-var="deployment_name=${DEPLOYMENT_NAME}" 
```

## Apply plan
```
terraform apply plan
```

## Invoke Lambda
``` 
aws lambda invoke \
    --function-name <deployment name>_dashboard_prep \
    output_file.txt \
    --log-type Tail \
    --query 'LogResult' --output text | base64 --decode
```

## Access your dashboard

Access the dashboard on your dashboard and you are ready to go! 



# Clean up

If you wish to tear down your environment, follow the steps below:

This will delete the AWS EFS Vault backups.
```
./pre-delete.sh -v panintelligence_efs_backup_<deployment name>
```

Afterwards, you can use terraform to tear down your environment:
```
terraform destroy   -var="region=${REGION}"   -var="hosted_zone_edit_role_arn=${HOSTED_ZONE_EDIT_ROLE_ARN}"   -var="hosted_zone_id=${HOSTED_ZONE_ID}"   -var="dashboard_db_password=${DASHBOARD_DB_PASSWORD}"   -var="dashboard_db_username=${DASHBOARD_DB_USERNAME}"   -var="licence_key=${LICENCE_KEY}"   -var="certificate_arn=${CERTIFICATE_ARN}"   -var="pi_proxy_host=${PI_PROXY_HOST}"   -var="renderer_dashboard_url=${RENDERER_DASHBOARD_URL}"   -var="docker_hub_credentials={\"username\":\"${GITHUB_CREDENTIALS_USERNAME}\",\"password\":\"${GITHUB_CREDENTIALS_PASSWORD}\"}"   -var="deployment_name=${DEPLOYMENT_NAME}"

```
# Support
Please contact support@panintelligence.com