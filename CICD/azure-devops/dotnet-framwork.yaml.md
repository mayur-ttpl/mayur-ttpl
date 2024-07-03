trigger: none

pool:
  vmImage: 'windows-2022'

variables:
  solution: '**/*.sln'
  buildPlatform: 'Any CPU'
  buildConfiguration: 'Release'
  project_name: 'MvcApplication'

steps:
- task: NuGetToolInstaller@1
  name: 'NuGetToolInstall'
  displayName: 'install Nuget Tool'
- task: NuGetCommand@2
  name: 'NuGetCommand'
  displayName: 'Nuget command'
  inputs:
    restoreSolution: '$(solution)'
- task: VSBuild@1
  name: 'msbuild'
  displayName: 'Build the project'
  inputs:
    solution: '$(solution)'
    #msbuildArgs: '/p:DeployOnBuild=true /p:WebPublishMethod=Package /p:PackageAsSingleFile=true /p:SkipInvalidConfigurations=true /p:PackageLocation="$(build.artifactStagingDirectory)"'
    msbuildArgs: /p:DeployOnBuild=true /p:WebPublishMethod=Package /p:PackageAsSingleFile=true /p:SkipInvalidConfigurations=true /p:PackageLocation="$(build.artifactstagingdirectory)\\"  /p:UseWPP_CopyWebApplication=true  /p:OutDir="$(build.artifactstagingdirectory)" 
    platform: '$(buildPlatform)'
    configuration: '$(buildConfiguration)'
    clean: true
- task: PublishBuildArtifacts@1
  name: 'publishArtifact'
  displayName: 'Publish Artifact'
  inputs:
    #PathtoPublish: '$(Build.ArtifactStagingDirectory)'
    PathtoPublish: '$(Build.ArtifactStagingDirectory)\_PublishedWebsites'
    ArtifactName: 'drop'
    publishLocation: 'Container'
- task: DownloadBuildArtifacts@1
  name: 'DownloadBuildArtifacts'
  displayName: 'Download Build Artifacts on azure agent[custom/managed]'
  inputs:
    buildType: 'current'
    downloadType: 'single'
    artifactName: 'drop'
    itemPattern: |
      **
      !FirefoxDriver/**
    downloadPath: '$(System.ArtifactsDirectory)'
    cleanDestinationFolder: true
- powershell: | 
    Write-Host "Removing the 'FirefoxDriver' subfolder from artifacts..."
    Remove-Item -Recurse -Force "$(System.ArtifactsDirectory)\drop\$(project_name)\FirefoxDriver"
    Write-Host "Removing the 'web.config' file from artifacts..."
    Remove-Item -Force "$(System.ArtifactsDirectory)\drop\$(project_name)\web.config"
  displayName: 'Remove FirefoxDriver subfolder'
- task: 7z@1
  name: 'zipartifact'
  displayName: 'zip the artifact'
  inputs:
    Folder: '$(System.ArtifactsDirectory)\drop\$(project_name)'
    Archive: '$(System.ArtifactsDirectory)\$(project_name).zip'
    ArchiveFormat: 'zip'
- task: S3Upload@1
  name: 's3upload'
  displayName: 'upload artifact to s3'
  inputs:
    awsCredentials: 'AWS-admin-service-account'
    regionName: 'us-east-1'
    bucketName: '<bucket-name-here>'
    sourceFolder: '$(System.ArtifactsDirectory)'
    globExpressions: '**/*.zip'
    targetFolder: 'NOaaS/QA/'
    filesAcl: 'bucket-owner-full-control'
