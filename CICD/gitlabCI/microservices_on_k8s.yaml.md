##image: openjdk:11

before_script:
  - export GRADLE_USER_HOME=`pwd`/.gradle
  - docker login registry.gitlab.com -u $CI_REGISTRY_USER -p $CI_REGISTRY_TOKEN

stages:
  - prod-build

cache:
  paths:
    - .gradle/wrapper
    - .gradle/caches
    - docker/*.txt

##### Prod jobs #####

## Prod build app jobs

job prod-app-build:
  stage: prod-build
  only:
    refs:
      - prod_release_15072023
    changes:
      - app/**/*
      - platform/**/*
      - core/**/*
  script:
    - mv app/src/main/resources/prod-application.properties app/src/main/resources/application.properties
    - ./gradlew :app:clean :app:bootJar
    - echo "Building Docker Image..."
    - ./gradlew :app:docker :app:currentVersion
    - ./gradlew :app:dockerPushGitlab
    - ls docker/placeholder-server-app_tag.txt
    - chmod 400 placeholder-management-server-keypair.pem
    - scp -o 'StrictHostKeyChecking no' -i placeholder-management-server-keypair.pem -r docker/placeholder-server-app_tag.txt ubuntu@1.1.1.1:~/prod_tag/

## Prod build captcha jobs

job prod-captcha-build:
  stage: prod-build
  only:
    refs:
      - prod_release_15072023
    changes:
      - captcha/**/*
      - core/**/*
  script:
    - ./gradlew :captcha:clean :captcha:bootJar
    - echo "Building Captcha Docker Image..."
    - ./gradlew :captcha:docker :captcha:currentVersion
    - ./gradlew :captcha:dockerPushGitlab
    -  ls docker/placeholder-server-captcha_tag.txt
    -  chmod 400 placeholder-management-server-keypair.pem
    -  scp -o 'StrictHostKeyChecking no' -i placeholder-management-server-keypair.pem -r docker/placeholder-server-captcha_tag.txt ubuntu@1.1.1.1:~/prod_tag/

## Prod build jobapp jobs

job prod-jobapp-build:
  stage: prod-build
  only:
    refs:
      - prod_release_15072023
    changes:
      - jobapp/**/*
      - platform/**/*
      - core/**/*
  script:
    - mv jobapp/src/main/resources/prod-application.properties jobapp/src/main/resources/application.properties
    - ./gradlew :jobapp:clean :jobapp:bootJar
    - echo "Building Docker Image..."
    - ./gradlew :jobapp:docker :jobapp:currentVersion
    - ./gradlew :jobapp:dockerPushGitlab
    - ls docker/placeholder-server-jobapp_tag.txt
    - chmod 400 placeholder-management-server-keypair.pem
    - scp -o 'StrictHostKeyChecking no' -i placeholder-management-server-keypair.pem -r docker/placeholder-server-jobapp_tag.txt ubuntu@1.1.1.1:~/prod_tag/

## Prod build notification jobs

job prod-notification-build:
  stage: prod-build
  only:
    refs:
      - prod_release_15072023
    changes:
      - notification/**/*
      - core/**/*
  script:
    - mv notification/src/main/resources/prod-application.properties notification/src/main/resources/application.properties
    - ./gradlew :notification:clean :notification:bootJar
    - echo "Building Notification Docker Image..."
    - ./gradlew :notification:docker :notification:currentVersion
    - ./gradlew :notification:dockerPushGitlab
    -  ls docker/placeholder-server-pushnotify_tag.txt
    -  chmod 400 placeholder-management-server-keypair.pem
    -  scp -o 'StrictHostKeyChecking no' -i placeholder-management-server-keypair.pem -r docker/placeholder-server-pushnotify_tag.txt ubuntu@1.1.1.1:~/prod_tag/

## Prod build emailnotify jobs

job prod-emailnotify-build:
  stage: prod-build
  only:
    refs:
      - prod_release_15072023
    changes:
      - emailnotify/**/*
      - core/**/*
  script:
    - mv emailnotify/src/main/resources/prod-application.properties emailnotify/src/main/resources/application.properties
    - ./gradlew :emailnotify:clean :emailnotify:bootJar
    - echo "Building Emailnotify Docker Image..."
    - ./gradlew :emailnotify:docker :emailnotify:currentVersion
    - ./gradlew :emailnotify:dockerPushGitlab
    - ls docker/placeholder-server-emailnotify_tag.txt
    - chmod 400 placeholder-management-server-keypair.pem
    - scp -o 'StrictHostKeyChecking no' -i placeholder-management-server-keypair.pem -r docker/placeholder-server-emailnotify_tag.txt ubuntu@1.1.1.1:~/prod_tag/

## Prod build smsnotify jobs

job prod-smsnotify-build:
  stage: prod-build
  only:
    refs:
      - prod_release_15072023
    changes:
      - smsnotify/**/*
      - core/**/*
  script:
    - mv smsnotify/src/main/resources/prod-application.properties smsnotify/src/main/resources/application.properties
    - ./gradlew :smsnotify:clean :smsnotify:bootJar
    - echo "Building smsnotify Docker Image..."
    - ./gradlew :smsnotify:docker :smsnotify:currentVersion
    - ./gradlew :smsnotify:dockerPushGitlab
    - ls docker/placeholder-server-smsnotify_tag.txt
    - chmod 400 placeholder-management-server-keypair.pem
    - scp -o 'StrictHostKeyChecking no' -i placeholder-management-server-keypair.pem -r docker/placeholder-server-smsnotify_tag.txt ubuntu@1.1.1.1:~/prod_tag/

## Prod build wellnessapp job
#
#job prod-wellnessapp-build:
#  stage: prod-build
#  only:
#    refs:
#      - prod_release_30122022
#    changes:
#      - wellnessapp/**/*
#      - platform/**/*
#      - core/**/*
#  script:
#    - mv wellnessapp/src/main/resources/prod-application.properties wellnessapp/src/main/resources/application.properties
#    - ./gradlew :wellnessapp:clean :wellnessapp:bootJar
#    - echo "Building wellnessapp Docker Image..."
#    - ./gradlew :wellnessapp:docker :wellnessapp:currentVersion
#    - ./gradlew :wellnessapp:dockerPushGitlab
#    - ls docker/placeholder-server-wellness_tag.txt
#    - chmod 400 placeholder-management-server-keypair.pem
#    - scp -o 'StrictHostKeyChecking no' -i placeholder-management-server-keypair.pem -r docker/placeholder-server-wellness_tag.txt ubuntu@1.1.1.1:~/prod_tag/


## PROD build store jobs
job prod-store-build:
  stage: prod-build
  only:
    refs:
      - prod_release_15072023
    changes:
      - store/**/*
      - platform/**/*
      - core/**/*
  script:
    - mv store/src/main/resources/prod-application.properties store/src/main/resources/application.properties
    - ./gradlew :store:clean :store:bootJar
    - echo "Building store Docker Image..."
    - ./gradlew :store:docker :store:currentVersion
    - ./gradlew :store:dockerPushGitlab
    - ls docker/placeholder-server-store_tag.txt
    - chmod 400 placeholder-management-server-keypair.pem
    - scp -o 'StrictHostKeyChecking no' -i placeholder-management-server-keypair.pem -r docker/placeholder-server-store_tag.txt ubuntu@1.1.1.1:~/prod_tag/

## PROD build report jobs
job prod-report-build:
  stage: prod-build
  only:
    refs:
      - prod_release_15072023
    changes:
      - report/**/*
      - platform/**/*
      - core/**/*
  script:
    - mv report/src/main/resources/prod-application.properties report/src/main/resources/application.properties
    - ./gradlew :report:clean :report:bootJar
    - echo "Building report Docker Image..."
    - ./gradlew :report:docker :report:currentVersion
    - ./gradlew :report:dockerPushGitlab
    - ls docker/placeholder-report-server_tag.txt
    - chmod 400 placeholder-management-server-keypair.pem
    - scp -o 'StrictHostKeyChecking no' -i placeholder-management-server-keypair.pem -r docker/placeholder-report-server_tag.txt ubuntu@1.1.1.1:~/prod_tag/

after_script:
  - docker logout registry.gitlab.com
  - echo "End CI"
