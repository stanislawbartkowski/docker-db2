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
    
* Build the image

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


