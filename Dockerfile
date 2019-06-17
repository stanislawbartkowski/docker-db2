FROM centos as intermediate

MAINTAINER "sb" <stanislawbartkowski@gmail.com>

ARG INSTDIR
ARG PARS
ARG FIXDIR

# parameters doe AESE
#ARG PARS=-p\ SERVER
# parameters for Express-C
#ARG PARS=-y
ARG INSTPATH=/opt/ibm/db2/V11.1

# update system and install DB2 dependencies
 RUN yum -y update ; yum -y install file libaio numactl libstdc++.so.6 pam-devel ksh pam-devel.i686 'compat-libstdc++-33-3.2.3-72.*'

 ADD ibm-xl-compiler-eval.repo /etc/yum.repos.d/ibm-xl-compiler-eval.repo
 RUN if [ "$HOSTTYPE" == "powerpc64le" ]; then yum -y install 'libxlc*'; fi

# copy installation image
 ADD ${INSTDIR} /tmp/i
# install
 RUN /tmp/i/db2_install ${PARS} -b ${INSTPATH} -f NOTSAMP 
# install fixpack, true added to suppress exit error code
 RUN if [ "${FIXDIR}" != "" ] ; then /tmp/i/${FIXDIR}/installFixPack -b ${INSTPATH} -n; true; fi
 RUN rm -rf /tmp/i

FROM centos 
# from intermediate image copy installation and db2 registry leaving out the installation image
  COPY --from=intermediate /opt /opt
  RUN mkdir -p  /var/db2
  COPY --from=intermediate /var/db2 /var/db2

  ARG INSTDIR
  ARG INSTPATH=/opt/ibm/db2/V11.1
  ARG DB2USER=db2inst1
  ARG DB2PASSWORD=db2inst1
  ARG DB2PORT=50000
  ENV DB2USER=${DB2USER}


# update system and install DB2 dependencies again
  RUN yum -y update ; yum -y install file libaio numactl libstdc++.so.6 pam-devel ksh pam-devel.i686 'compat-libstdc++-33-3.2.3-72.*'

 ADD ibm-xl-compiler-eval.repo /etc/yum.repos.d/ibm-xl-compiler-eval.repo
 RUN if [ "$HOSTTYPE" == "powerpc64le" ]; then yum -y install 'libxlc*'; fi

# users and password
  RUN useradd ${DB2USER}
  RUN useradd db2fenc1
  RUN echo "${DB2USER}:${DB2PASSWORD}" | chpasswd

# create instance
  RUN ${INSTPATH}/instance/db2icrt -p ${DB2PORT} -u db2fenc1 ${DB2USER}

EXPOSE ${DB2PORT}

ADD ./main.sh main.sh

ENTRYPOINT ["./main.sh"]
