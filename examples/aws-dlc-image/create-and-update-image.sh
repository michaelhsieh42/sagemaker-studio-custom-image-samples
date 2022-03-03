ACCOUNT_ID=123456789012                         # your AWS account ID
REGION=us-east-1                                # your region
DOMAINID=d-xxxxxxxxxxxx                         # your SageMaker Studio domain ID.
ROLE_ARN='<IAM-Execution-Role-ARN>'             # your SageMaker execution role to create image
IMAGE_NAME=pytorch-191-transformer-4.12.3-gpu   # the image name to be shown in SageMaker Studio
REPO=huggingface-pytorch-training               # ECR repository name
TAG=1.9.1-transformers4.12.3-gpu-py38-cu111-ubuntu20.04  # image tag

# login to own ECR and public DLC's ECR
aws --region ${REGION} ecr get-login-password | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com
aws --region ${REGION} ecr get-login-password | docker login --username AWS --password-stdin 763104351884.dkr.ecr.${REGION}.amazonaws.com

# create repo
aws --region ${REGION} ecr create-repository --repository-name ${REPO}

# build docker image and push to ECR
docker build . -t ${REPO}:${TAG} -t ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO}:${TAG}

docker push ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO}:${TAG}

# Will throw an error gracefully if $IMAGE_NAME exists
aws --region ${REGION} sagemaker create-image \
    --image-name ${IMAGE_NAME} \
    --role-arn ${ROLE_ARN}

aws --region ${REGION} sagemaker create-image-version \
    --image-name ${IMAGE_NAME} \
    --base-image "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO}:${TAG}"
    
# Verify the image-version is created successfully. Do NOT proceed if image-version is in CREATE_FAILED state or in any other state apart from CREATED.
aws --region ${REGION} sagemaker describe-image-version \
    --image-name ${IMAGE_NAME}

## Create AppImageConfig for this image (modify AppImageConfigName and KernelSpecs in app-image-config-input.json as needed)
aws --region ${REGION} sagemaker create-app-image-config \
    --cli-input-json file://app-image-config-input.json

## Update the Domain, providing the Image and AppImageConfig
aws --region ${REGION} sagemaker update-domain \
    --domain-id ${DOMAINID} \
    --cli-input-json file://default-user-settings.json
