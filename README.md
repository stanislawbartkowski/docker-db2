# docker-db2

This project allows to Dockerize IBM DB2 database. The image will contains DB2 installation and a single instance ready to accept connections.

# Preparation and prerequisities

## Clone git project
> git clone https://github.com/stanislawbartkowski/docker-db2.git<br>
> cd docker-db2<br>
## Prepare DB2 installation image
Download and unpack IBM DB2 installation image into *docker-db2* folder. Only unpacked files should be moved there, without source *.gz* or *.zip* file.<br>
For instance, after unpacking AESE Edition of DB2, the directory structure should look.
* docker-db2
  * main.sh
  * Dockerfile
  * server_aese_c
    * db2  
    * db2checkCOL_readme.txt  
    * db2checkCOL.tar.gz  
    * db2ckupgrade  
    * db2_deinstall  
    * db2_install  
    * db2ls  
    * db2prereqcheck  
    * db2setup  
    * ibm_im  
    * installFixPack  nlpack
    
# Build the Docker image

## Customization

*INSTDIR* argument is necessary for building process . It is the root directory for DB2 installation files. In the above example, the INSTDIR should be **server_aese_c**.
The Docker image can be customized by several build variables.

| Variable name     | Default           | Description
| ------------- | -------------| ----- |
| INSTDIR | Mandatory, no default | The root path of unpacked DB2 installation files
| INSTPATH | /opt/ibm/db2/V11.1 | Installation path for DB2, the path inside container file syste,
| DB2USER | db2inst1 | DB2 instance owner
| DB2PORT | 50000 | DB2 TCP/IP connection port
| DB2PASSWORD | db2inst1 | DB2 instance owner password

Important: Even if the default password is changed, it can be easily extracted by running *docker history* whatsoever. In order to keep the password confidential, change it later in the container manually.

## Build the image
You can change the image name (here *db2*) to any other name.

> docker build --build-arg INSTDIR=server_aese_c  -t db2  .<br>

The building process takes several minutes. Intermediate image is created to get rid of DB2 installation files which are redundant after installation and to avoid pumping up the image size. So the *yum update* and *yum install* commands are execute twicely, once inside the intermediate image and the second time inside the final image.

During DB2 installation the following error message can be reported, just ignore it.
```
The execution completed successfully.

For more information see the DB2 installation log at 
"/tmp/db2_install.log.1".
The command execution aborted due to user interrupt. 
Removing intermediate container 8c458c798a36

```
After image is completed, remove the intermediate image.
> docker image prune

# Start the container

## Initialize
The container should run as *--privileged*. The name of the container (here *db2*) could be any other.

 > docker run --privileged -d -p 50000:50000 --name db2 db2

First thing to do is to create a database, the image contains empty DB2 instance. The container DB2 instance can be accessed remotely, using DB2 client software.
## Remote access to DB2 instance
> db2 catalog tcpip node DB2CONT remote localhost server 50000<br>
```
DB20000I  The CATALOG TCPIP NODE command completed successfully.
DB21056W  Directory changes may not be effective until the directory cache is 
refreshed.
```
## Create database
>  db2 attach to  DB2CONT user db2inst1
```
Enter current password for db2inst1: 

   Instance Attachment Information

 Instance server        = DB2/LINUXX8664 11.1.0
 Authorization ID       = DB2INST1
 Local instance alias   = DB2CONT

```

