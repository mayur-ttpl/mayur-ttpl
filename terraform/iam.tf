# IAM role for EC2 with ECR full access
resource "aws_iam_role" "ec2_ecr_full_access_new_role" {
  name               = "ec2_ecr_full_access_new_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# Attach policy to the IAM role
resource "aws_iam_role_policy_attachment" "ec2_ecr_full_access_new_attachment" {
  role       = aws_iam_role.ec2_ecr_full_access_new_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

# Instance profile for EC2 with ECR full access
resource "aws_iam_instance_profile" "EC2ECRFullAccessProfile" {
  name = "EC2ECRFullAccessProfile"

  role= aws_iam_role.ec2_ecr_full_access_new_role.name
}
