# DockeRfile - A base file to allow the creation of R Docker containers images

### Sections:
- Goal of the project
- Best practices
  - security
- Pre-requisites
- Building your first image
- Local builds
- Building on hosting services
- CICD

## Goal

This project is designed to provide an alternative to the very useful and successful [Rocker Project](https://rocker-project.org/). While there will be some functional overlap between this project and Rocker, there are some differences between each that, I hope, will make this project useful.

This project is designed to be a training tools to allow R practitioners to use containers in their work. To this end the choice has been made to provide collection of files that can be used by R practitioners to create their own R Docker images in a relatively simple and transparent manner. To this end the example Dockerfile that is present in this project will build a base R system from scratch with minimal additional tooling of R library inclusion. The only exception to this will be the inclusion of the `devtools` library so that the compilation of R libraries published outside of CRAN can be included in a container.

The latter point becomes of greater importance when dealing with secured research platforms that may not allow direct access to one of more resources (such as GitHub or BitBucket).

## Best Practices

The Dockerfile has tried to stick to a number of best practices in the building of containers such as:
- fixing the versions of installed OS packages
- using external config files and scripts to minimise the changes needed to the Dockerfile itself

Fixing versions of OS and R packages can be a powerful tool for ensuring that the analysis environment is stable across platforms (local, HPC, Cloud, Reseach Environments) and can ensure that collaborators across institutions are working from the same basis.

It is recommended that this project be forked into a repository under your own github account. This will allow you to build images in the following ways:
- locally with an installation of the Docker Engine for your operating system
- using [GitHub Actions](https://github.com/marketplace/actions/build-and-push-docker-images)
- using a container hosting service such as Dockerhub or Quay.io

### Security
While containers will provide a static and stable working environment it is important to mote that a container will run its own operating system, which is static, and will not be automatically updated with security patches. It is therefore strongly recommended that all containers built are checked for vulnerabilities when first built, and at regular intervals so as to reduce the introduction of vulnerabilities to your working environment.
There are a number of scanning tools that can be used. Most hosting sites will have their own built in tooling to provide you with this information.

The following are an example of actively developed open-source projects which could help:
- [trivy](https://github.com/aquasecurity/trivy)
- [clair](https://github.com/quay/clair)
- [grype](https://github.com/anchore/grype)
- [grafeas](https://github.com/grafeas/grafeas)
- [dagda](https://github.com/eliasgranderubio/dagda )

If you are going to use a local scanning tool it can be useful to have some form of tracking process to ensure that scans are performed regularly and that vulnerabilities are removed as and when they fixed by their respective developers. [vimp](https://github.com/mchmarny/vimp) is one such tool that can help with this.

While it is desirable to fix the package versions to ensure stability, this does need to be balance against the need to reduce exposure to vulnerabilities. In some instances this may be a requirement for using these types of tools within certain analysis platform providers.

## Building an R Docker image

The simplest way to learn how to use this repository will be to start building your container images locally. For this you will need to ensure that you have both `git` and the appropriate version of Docker Desktop for your system installed. Once installed you can build a test image using the command:
```bash
docker build -t r_docker:test -f DockeRfile .
```

In order to include the packages that you need in your dockerfile the easiest methold will be to edit the `Install_packages.R` file to list the package names that are needed. For example:
```R
# package installer script for Dockerfile
### comment out segments as appropriate

## CRAN R packages

CRAN_Package_List <- c('tidyverse', 'vcfR')
install.packages(CRAN_Package_List)

## GitHub packages

GitHub_Package_List <- c('PheWAS/PheWAS"' 'caravagnalab/mobster')
devtools::install_github(GitHub_Package_List)

## GitLab packages

GitLab_Package_List <- c('r-packages/ufs', 'r-packages/rock')
devtools::install_gitlab(GitLab_Package_List)

## BitBucket packages

BitBucket_Package_List <- c()
devtools::install_bitbucket(BitBucket_Package_List)

## Local packages

Local_Package_List <- c()
devtools::install_local(Local_Package_List)
```

Once you have confirmed that the container in question can be built locally we strongly recommend that functional tests be performed to ensure that the package produces the expected outputs.

Once you are satisfied that the the designed container will fit the needs of your work we recommend that you attach your repository to your chosen host to allow the build process to be performed by the hosting service.

### A note on Layers

Docker containers use a collection of unchangeable (immutable) layers to construct the container. Each of these layers is defined in the Dockerfile by the `RUN` command. The design is intended to allow different containers to re-use layers that are defined in the same way between images. While this reduces the storage needed to build similar containers locally and, on the compute side, will allow resources to be shared between containers efficiently it does come at a cost of increased size if the image needs to be pulled/imported into a different environment for working.

One important thing to note: not all analysis platforms will allow the use of Docker containers natively, however, Singularity/Apptainer is a container solution that allows:
- containers to run without `root` privileges
- is able to convert Docker images to its native format as part of the pull process

Singularity/Apptainer files using the `*.sif` extension are self-contained files that do away with the layers within the Docker image. 

### Troubleshooting notes
Some packages may depend on OS libraries which are not installed by default by this example file. One of the reasons we recommend a local test build is that these dependencies are likely to be flagged in any build errors. OS dependencies reported by R can then be added to the:
```bash
apt-get install 
```
list of system packages.

If a package install is proving to be particularly tricky it may be worth investigating the steps needed successfully complete the installation within an interactive session. 

For testing and tinkering the best way of doing this will be to use the following command from your terminal:
`docker run --rm -it <image_name>:<tag> /usr/bin/bash` where `-it` specifies that the session will be interactive; `--rm` instructs docker not to save any changes to the container (very useful for situations where mistakes may take place and you may need to start from a fresh slate); and `/usr/bin/bash` to ensure that the session will start the Bourne Again SHell which will allow you to use common CLI commands.


The direct feedback that you will get will help you design and build your container. Once you have successfully installed your tools in the interactive session you can recover a list of the commands used using the `history` command. Copying these into a text editor will allow you to:
- remove steps that were unsuccessful
- group OS package installs that you found were needed to successfully complete the installation
- groups commands together to reduce the layers in your container

## Using your container
containers are self-contained environments which are functionally isolated from the host system. Without default access to the filesystem the container will have not be able to either access the data that you need to analyse not export the results for you to further process, share or publish. You should consult the appropriate documentation for file mounting for the technology that you are using:
- for [Docker](https://docs.docker.com/engine/storage/bind-mounts/)
- for [Singularity/Apptainer](https://apptainer.org/user-docs/master/bind_paths_and_mounts.html#:~:text=You%20can%20mount%20from%20image,image%20in%20a%20single%20container.)