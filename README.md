# docker-db2

This project allows to Dockerize IBM DB2 database. The image will contain DB2 installation and a single instance ready to accept connections. Database(s) should be added manually.

Look also: https://www.ibm.com/support/knowledgecenter/SSEPGG_11.5.0/com.ibm.db2.luw.db2u_openshift.doc/doc/t_install_db2CE_linux_img.html

# Preparation and prerequisites

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
    
For DB2 Express-C edition

* docker-db2
  * main.sh
  * Dockerfile
  * expc
    * db2  
    * db2ckupgrade  
    * db2_deinstall  
    * db2_install  
    * db2ls  
    * db2prereqcheck  
    * db2setup  

# Build the Docker image

## Customization

Important: *podman* is also supported. Just replace every reference to *docker* with *podman* or install *podman-docker* package.

*INSTDIR* argument is necessary for building process. It is the root directory for DB2 installation files. In the above example, the INSTDIR should be **server_aese_c**.<br>
Also argument *PARS* is mandatory. It is an additional parameter for IBM DB2 installer specific to the particular DB2 version. Incorrect value will cause installation failure difficult to pin down.<br>
The Docker image can be customized by several build variables.

| Variable name     | Default           | Description
| ------------- | -------------| ----- |
| INSTDIR | Mandatory, no default | The root path of unpacked DB2 installation files
| INSTPATH | /opt/ibm/db2/V11.1 | Installation path for DB2, the path inside container file syste,
| DB2USER | db2inst1 | DB2 instance owner
| DB2PORT | 50000 | DB2 TCP/IP connection port
| DB2PASSWORD | db2inst1 | DB2 instance owner password
| PARS | Mandatory, no default | Additional parameter passed to DB2 installer. For AESE the value should be **-b\ SERVER**, for DB2 Express-C **-y**
| FIXDIR | not defined | root directory for DB2 FixPack, look below. If not defined, only main installation is conducted.

Important: Even if the default password is changed, it can be easily extracted by running *docker history* whatsoever. In order to keep the password confidential, change it later in the container manually.

## Build the image
You can change the image name (here *db2*) to any other name.

DB2 Express-C

>  docker build --build-arg INSTDIR=expc --build-arg PARS=-y -t db2 .<br>

DB2 AESE

> docker build --build-arg INSTDIR=server_aese_c --build-arg PARS=-p\ SERVER -t db2 .<br>

DB2 11.5, "IBM DB2 Developer-C Edition"

> docker build --build-arg INSTDIR=server_dec --build-arg INSTPATH=/opt/ibm/db2/V11.5 --build-arg PARS='-p SERVER -y' -t db2 .<br>

The building process takes several minutes.  An intermediate image is created to get rid of DB2 installation files which are redundant after installation and to avoid pumping up the image size. So the *yum update* and *yum install* commands are execute twice, once inside the intermediate image and the second time inside the final image.

During DB2 installation the following error message can be reported, just ignore it.
```
The execution completed successfully.

For more information see the DB2 installation log at 
"/tmp/db2_install.log.1".
The command execution aborted due to user interrupt. 
Removing intermediate container 8c458c798a36

```
After the image is completed, remove the intermediate image.

> docker image prune

## Apply IBM DB2 FixPack

Together with DB2 installation, the FixPack can applied at the same time. This option is available only for licensed version of DB2, DB2 Express-C cannot be upgraded that way.

Firstly unpack compressed file containing FixPack payload into DB2 installation directory. After unpacking the FixPack, the installation directory should look:
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
    * server_t
      * db2  
      * db2checkCOL_readme.txt  
      * db2checkCOL.tar.gz  
      * db2ckupgrade  db2_deinstall  
      * db2_install  db2ls  
      * db2prereqcheck  
      * db2setup  
      * ibm_im  
      * installFixPack

Then run docker build image command and define additional *FIXDIR* argument equal to root directory of FixPack files inside main install directory (here *server_t*)

> docker build --build-arg INSTDIR=server_aese_c --build-arg PARS="-p SERVER" --build-arg FIXDIR=server_t -t db2 .<br>

> docker build --build-arg INSTDIR=server_dec --build-arg INSTPATH=/opt/ibm/db2/V11.5 --build-arg PARS='-p SERVER -y' --build-arg FIXDIR=universal -t db2 .<br>
<br>

After main installation, the build process executes ${FIXDIR}/installFixPack command with appropriate parameters.

# Power LE

Db2 on PowerPC platform requires additional dependency. It is resolved by command:<br>
> ADD ibm-xl-compiler-eval.repo /etc/yum.repos.d/ibm-xl-compiler-eval.repo<br>
> RUN if [ "$HOSTTYPE" == "powerpc64le" ]; then yum -y install 'libxlc*'; fi<br>

# Start the container

## Initialize
The container should run as *--privileged*. The name of the container (here *db2*) could be any other.

 > docker run --privileged -d -p 50000:50000 --name db2 db2

The very first thing to do is to create a database, the image contains an empty DB2 instance. The container DB2 instance can be accessed remotely, using DB2 client software.

## External volume for container

Assuming external storage for DB2 container */disk/db2inst1*. It maps */home/db2inst1/db2inst1* into host node directory */disk/db2inst1*.

> podman run -v /home/repos/db2inst1:/home/db2inst1/db2inst1 -d -p 50000:50000 --name db2 db2

SELinux<br>

> semanage fcontext -a -t container_file_t '/disk/db2inst1(/.*)?'  <br>
> restorecon -R /disk/db2inst1

Verify<br>

> ls -lZd /disk/db2inst1<br>
```
drwxrwxrwx. 3 root root unconfined_u:object_r:container_file_t:s0 22 11-23 13:46 /disk/db2inst1
```

## Remote access to DB2 instance
> db2 catalog tcpip node DB2CONT remote localhost server 50000<br>
```
DB20000I  The CATALOG TCPIP NODE command completed successfully.
DB21056W  Directory changes may not be effective until the directory cache is 
refreshed.
```
## Create a database
>  db2 attach to  DB2CONT user db2inst1
```
Enter current password for db2inst1: 

   Instance Attachment Information

 Instance server        = DB2/LINUXX8664 11.1.0
 Authorization ID       = DB2INST1d
 Local instance alias   = DB2CONT

```
> db2 create database DB2DB<br>

Database creation will take several minutes, it is as expected.
```
DB20000I  The CREATE DATABASE command completed successfully.

```
> db2 list db directory
```
.......
 Database alias                       = DB2DB
 Database name                        = DB2DB
 Node name                            = DB2CONT
 Database release level               = 14.00
 Comment                              =
 Directory entry type                 = Remote
 Catalog database partition number    = -1
 Alternate server hostname            =
 Alternate server port number         =
........
```
## Connect to database
> db2 connect to DB2DB user db2inst1
```
Enter current password for db2inst1: 

   Database Connection Information

 Database server        = DB2/LINUXX8664 11.1.0
 SQL authorization ID   = DB2INST1
 Local database alias   = DB2DB

```
# Several useful commands
Stop the container
> docker stop db2

Start the container
> docker start db

Get access to the container. The instance owner password can be changed this way.
> docker exec -it db2 /bin/bash
