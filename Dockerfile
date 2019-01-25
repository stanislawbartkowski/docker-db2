FROM centos as intermediate

MAINTAINER "sb" <stanislawbartkowski@gmail.com>

ARG INSTDIR
ARG PROD=SERVER
ARG INSTPATH=/opt/ibm/db2/V11.1

# update system and install DB2 dependencies
 RUN yum -y update ; yum -y install file libaio numactl libstdc++.so.6 pam-devel ksh pam-devel.i686 'compat-libstdc++-33-3.2.3-72.*'

# start systemd
 ADD ${INSTDIR} /tmp/i
 RUN /tmp/i/db2_install -p ${PROD} -b ${INSTPATH} -f NOTSAMP
 RUN rm -rf 

FROM centos 
  COPY --from=intermediate /opt /opt
  RUN mkdir -p  /var/db2
  COPY --from=intermediate /var/db2 /var/db2

  ARG INSTDIR
  ARG INSTPATH=/opt/ibm/db2/V11.1
  ARG DB2USER=db2inst1
  ARG DB2PASSWORD=db2inst1
  ARG DB2PORT=50000
  ENV DB2USER=${DB2USER}


# update system and install DB2 dependencies
  RUN yum -y update ; yum -y install file libaio numactl libstdc++.so.6 pam-devel ksh pam-devel.i686 'compat-libstdc++-33-3.2.3-72.*'

# users and password
  RUN useradd ${DB2USER}
  RUN useradd db2fenc1
  RUN echo "${DB2USER}:${DB2PASSWORD}" | chpasswd

# create instance
  RUN ${INSTPATH}/instance/db2icrt -p ${DB2PORT} -u db2fenc1 ${DB2USER}

EXPOSE ${DB2PORT}

ADD ./main.sh main.sh

ENTRYPOINT ["./main.sh"]
