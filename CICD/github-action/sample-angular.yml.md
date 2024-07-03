#https://github.com/aws-actions/amazon-ecr-login/tree/main
#https://medium.com/@anshita.bhasin/build-and-push-docker-image-to-aws-ecr-using-github-actions-506e9f77f7f8
#https://docs.github.com/en/actions/publishing-packages/publishing-docker-images#publishing-images-to-docker-hub
name: Push To ECR
on:
  workflow_dispatch:
  push: 
    branches: [ "master" ]

#golbal varibale for CICD    
env:
  PRIVATE_KEY: ${{ secrets.TEST_SERVER_PRIVATE_KEY }}
  HOSTNAME: ${{secrets.TEST_SERVER_HOSTNAME}}
  USER_NAME: ec2-user
  CONTAINER_NAME: test-ui
  CONTAINER_PORT: 80
  
jobs:
  push-to-ecr:
    name: Build Docker Image
    runs-on: ubuntu-latest  
    steps:  
        - name: Checkout the repo
          uses: actions/checkout@v4          
        - name: Configure AWS credentials
          uses: aws-actions/configure-aws-credentials@v4
          with:
            aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
            aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
            aws-region: ${{secrets.AWS_REGION}}        
        - name: Login to Amazon ECR
          id: login-ecr
          uses: aws-actions/amazon-ecr-login@v2          
        - name: Build, tag, and push docker image to Amazon ECR
          env:
            REGISTRY: ${{ steps.login-ecr.outputs.registry }}
            REPOSITORY: ${{secrets.AWS_ECR_REPO}}
            IMAGE_SHA: ${{ github.sha }} #get full commit id 40 words
          run: |
            IMAGE_TAG=${IMAGE_SHA:0:7}  #extract first 7 letter from commit id
            echo "commit id to use as tag is: $IMAGE_TAG"
            docker build -t $REGISTRY/$REPOSITORY:$IMAGE_SHA .
            docker tag $REGISTRY/$REPOSITORY:$IMAGE_SHA $REGISTRY/$REPOSITORY:latest
            docker push $REGISTRY/$REPOSITORY:$IMAGE_SHA
            docker push $REGISTRY/$REPOSITORY:latest
            echo $REGISTRY/$REPOSITORY:$IMAGE_SHA > DOCKER_IMAGE_TAG.txt
            ls -lrth 
            cat DOCKER_IMAGE_TAG.txt            
        - name: Setup ssh connection with target and deployment
          run: |
            echo "$PRIVATE_KEY" > server_private.pem
            chmod 0600 server_private.pem
            ls -lrth
            cat server_private.pem
            
            #copy image name and tag to target server
            scp -o StrictHostKeyChecking=no -o LogLevel=ERROR -o UserKnownHostsFile=/dev/null -i server_private.pem DOCKER_IMAGE_TAG.txt $USER_NAME@$HOSTNAME:/tmp

            #deployement start on target server
            ssh -t -o StrictHostKeyChecking=no -o LogLevel=ERROR -o UserKnownHostsFile=/dev/null -i server_private.pem $USER_NAME@$HOSTNAME << 'EOF'
            export DOCKER_TAG=`cat /tmp/DOCKER_IMAGE_TAG.txt`
            sudo mkdir -p "${DOCKER_TAG}"
            echo "nginx:alpine" > image_name.txt
            export IMAGE=`cat image_name.txt`
            sudo docker rm -f test
            sudo docker run -itd -p 81:80 --name=test $IMAGE
            exit
            EOF
