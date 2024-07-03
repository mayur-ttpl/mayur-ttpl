#!/bin/bash
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""

echo $AWS_ACCESS_KEY_ID
echo $AWS_SECRET_ACCESS_KEY
#docker run -it --rm --name prowler-env -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY toniblyx/prowler --help

#working [for hipps]
#docker run -it --rm -v /root/test/prowler/hippa-results:/home/prowler/output --name prowler-env -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY toniblyx/prowler aws --compliance hipaa_aws

#for all scan
docker run -it --rm -v /root/test/prowler/hippa-results:/home/prowler/output --name prowler-env -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY toniblyx/prowler


