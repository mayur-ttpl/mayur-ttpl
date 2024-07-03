######to delete all build project history once #####
#!/bin/bash
##script to delete the build history from aws code build expect latest 50##
# Get the list of projects and store it in a variable
PROJECTS_NAME=$(aws codebuild list-projects | jq -r '.projects[]')
# Iterate through each project using a for loop
for PROJECT_NAME in $PROJECTS_NAME; do
    echo "Processing project: $PROJECT_NAME"
        #PROJECT_NAME="project-name-here"
        BUILD_LIST=`aws codebuild list-builds-for-project --project-name ${PROJECT_NAME} > ${PROJECT_NAME}.json`
        DATE_FORMAT=$(date +'%Y-%m-%d')

        #upto 50
        resource_ids_to_keep=$(jq -r '.ids[:50] | .[]' "${PROJECT_NAME}.json")

        #from 51
        resource_ids_to_delete=$(jq -r '.ids[50:] | .[]' "${PROJECT_NAME}.json")

        echo "$resource_ids_to_keep" > available_build_${PROJECT_NAME}_${DATE_FORMAT}.txt
        echo "$resource_ids_to_delete" > deleted_build_${PROJECT_NAME}_${DATE_FORMAT}.txt

# Loop through the resource IDs to delete
        for resource_id in $resource_ids_to_delete; do
                # Replace the following line with the AWS CLI command to delete the resource
                aws codebuild batch-delete-builds --ids "$resource_id" > /dev/null 2>&1
                echo "Deleted old resource ID"
        done
done

##############################################################################################################################################
##delete with associated files
#!/bin/bash
##script to delete the build history from aws code build expect latest 50##
# Get the list of projects and store it in a variable
PROJECTS_NAME=$(aws codebuild list-projects | jq -r '.projects[]')
# Iterate through each project using a for loop
for PROJECT_NAME in $PROJECTS_NAME; do
    echo "Processing project: $PROJECT_NAME"
        #PROJECT_NAME="project-name-here"
        BUILD_LIST=`aws codebuild list-builds-for-project --project-name ${PROJECT_NAME} > ${PROJECT_NAME}.json`
        DATE_FORMAT=$(date +'%Y-%m-%d')

        #upto 50
        resource_ids_to_keep=$(jq -r '.ids[:50] | .[]' "${PROJECT_NAME}.json")

        #from 51
        resource_ids_to_delete=$(jq -r '.ids[50:] | .[]' "${PROJECT_NAME}.json")

        echo "$resource_ids_to_keep" > available_build_${PROJECT_NAME}_${DATE_FORMAT}.txt
        echo "$resource_ids_to_delete" > deleted_build_${PROJECT_NAME}_${DATE_FORMAT}.txt

# Loop through the resource IDs to delete
        for resource_id in $resource_ids_to_delete; do
                # Replace the following line with the AWS CLI command to delete the resource
                aws codebuild batch-delete-builds --ids "$resource_id" > /dev/null 2>&1
                echo "Deleted old resource ID for project $PROJECT_NAME"
                echo "Deleted old resource ID for $PROJECT_NAME: $resource_id"
        done
#includes unset commands to remove the variables associated with each $PROJECT_NAME and rm commands to delete the files for each project at the end of each iteration
        unset PROJECT_NAME
        unset BUILD_LIST
        unset resource_ids_to_keep
        unset resource_ids_to_delete
        rm -f available_build_"$PROJECT_NAME"_"$DATE_FORMAT".txt
        rm -f deleted_build_"$PROJECT_NAME"_"$DATE_FORMAT".txt
done
#find . -type f ! -name '$script_name' -exec rm -f {} +

#############################################################################################################################################

######to delete single project history only############
#!/bin/bash
##script to delete the build history from aws code build expect latest 50##
PROJECT_NAME="project-name-here"
BUILD_LIST=`aws codebuild list-builds-for-project --project-name ${PROJECT_NAME} > ${PROJECT_NAME}.json`
DATE_FORMAT=$(date +'%Y-%m-%d')

#upto 50
resource_ids_to_keep=$(jq -r '.ids[:50] | .[]' "${PROJECT_NAME}.json")

#from 51
resource_ids_to_delete=$(jq -r '.ids[50:] | .[]' "${PROJECT_NAME}.json")

echo "$resource_ids_to_keep" > available_build_${PROJECT_NAME}_${DATE_FORMAT}.txt
echo "$resource_ids_to_delete" > deleted_build_${PROJECT_NAME}_${DATE_FORMAT}.txt

# Loop through the resource IDs to delete
for resource_id in $resource_ids_to_delete; do
    # Replace the following line with the AWS CLI command to delete the resource
    aws codebuild batch-delete-builds --ids "$resource_id" > /dev/null 2>&1
    echo "Deleted old resource ID"
done
