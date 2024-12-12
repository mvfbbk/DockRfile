# package installer script for Dockerfile
### comment out segments as appropriate

## CRAN R packages

CRAN_Package_List <- c()
install.packages(CRAN_Package_List)

## GitHub packages

GitHub_Package_List <- c()
devtools::install_github(GitHub_Package_List)

## GitLab packages

GitLab_Package_List <- c()
devtools::install_gitlab(GitLab_Package_List)

## BitBucket packages

BitBucket_Package_List <- c()
devtools::install_bitbucket(BitBucket_Package_List)

## Local packages

Local_Package_List <- c()
devtools::install_local(Local_Package_List)