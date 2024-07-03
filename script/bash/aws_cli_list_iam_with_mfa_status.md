#!/bin/bash

# Output CSV header
echo "Username,MFA Enabled"

# Get a list of IAM users
users=$(aws iam list-users --query "Users[*].UserName" --output text)

# Iterate through each user
for user in $users; do
    # Check if MFA is enabled for the user
    mfa_enabled=$(aws iam list-mfa-devices --user $user --query "MFADevices[*]" --output text)
    
    # Determine MFA status
    if [ -z "$mfa_enabled" ]; then
        mfa_status="No"
    else
        mfa_status="Yes"
    fi

    # Output the user's name and MFA status in CSV format
    echo "$user,$mfa_status"
done
