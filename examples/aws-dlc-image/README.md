## Build a custom notebook kernel from AWS Deep Learning Containers

### Overview
This custom image sample demonstrates how to create a custom kernel from AWS Deep Learning Containers (AWS DLC) for use in SageMaker Studio Notebook. 

The image must have the appropriate kernel package `ipykernel` installed. This example extends from a HuggingFace container from [AWS Deep Learning Container](https://github.com/aws/deep-learning-containers/blob/master/available_images.md#huggingface-training-containers) and installs some additional python libraries. This kernel image will be placed in SageMaker Studio as an custom image named `pytorch-191-transformer-4.12.3-gpu`.

The steps below are put into [create-and-update-image.sh](./create-and-update-image.sh) for convenience. You need to customize the four variables, `ACCOUNT_ID`, `REGION`, `DOMAINID`, and `ROLE_ARN` before you run the script.

### Building the image
Build the Docker image and push to Amazon ECR. 
```
# Modify these as required. The Docker registry endpoint can be tuned based on your current region from https://docs.aws.amazon.com/general/latest/gr/ecr.html#ecr-docker-endpoints
REGION=<aws-region>
ACCOUNT_ID=<aws-account-id>

IMAGE_NAME=pytorch-191-transformer-4.12.3-gpu

# login to own ECR and public DLC's ECR
aws --region ${REGION} ecr get-login-password | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com
aws --region ${REGION} ecr get-login-password | docker login --username AWS --password-stdin 763104351884.dkr.ecr.${REGION}.amazonaws.com

# create repo
aws --region ${REGION} ecr create-repository --repository-name ${REPO}

# build docker image and push to ECR
docker build . -t ${REPO}:${TAG} -t ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO}:${TAG}
docker push ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO}:${TAG}
```

### Using with SageMaker Studio

Create a SageMaker Image (SMI) with the image in ECR. 

```bash
# Role in your account to be used for SMI. Modify as required.

ROLE_ARN=arn:aws:iam::${ACCOUNT_ID}:role/RoleName
aws --region ${REGION} sagemaker create-image \
    --image-name ${IMAGE_NAME} \
    --role-arn ${ROLE_ARN}

aws --region ${REGION} sagemaker create-image-version \
    --image-name ${IMAGE_NAME} \
    --base-image "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO}:${TAG}"

# Verify the image-version is created successfully. Do NOT proceed if image-version is in CREATE_FAILED state or in any other state apart from CREATED.
aws --region ${REGION} sagemaker describe-image-version --image-name ${IMAGE_NAME}
```

Create a AppImageConfig for this image

```bash
aws --region ${REGION} sagemaker create-app-image-config --cli-input-json file://app-image-config-input.json

```

If you have an existing Domain, you can also use the `update-domain`

```bash
aws --region ${REGION} sagemaker update-domain --cli-input-json file://update-domain-input.json
```

Create a User Profile, and start a Notebook using the SageMaker Studio launcher.