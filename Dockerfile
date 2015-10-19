# Ubuntu 14.04 LTS
# Oracle Java 1.8.0_11 64 bit
# Maven 3.2.2
# git 1.9.1

# originally from stephenreed/jenkins-java8-maven-git
#FROM ubuntu:14.04
FROM maven:3.3-jdk-8

MAINTAINER Trever M. Shick (http://shick.io, trever@shick.io)

# this is a non-interactive automated build - avoid some warning messages
ENV DEBIAN_FRONTEND noninteractive

# update dpkg repositories
RUN apt-get update

# install git
RUN apt-get install -y curl git build-essential wget sudo python-software-properties
# these are for phantomjs
RUN apt-get install -y libfreetype6 fontconfig 

#install nodejs
RUN apt-get --purge remove node
RUN curl -sL https://deb.nodesource.com/setup_0.12 | sudo bash -
RUN apt-get install -y nodejs

# remove download archive files
RUN apt-get clean


# unpack java
#RUN mkdir /opt/java-oracle && tar -zxf /tmp/$filename -C /opt/java-oracle/
#ENV JAVA_HOME /opt/java-oracle/jdk$java_version
#ENV PATH $JAVA_HOME/bin:$PATH

# configure symbolic links for the java and javac executables
#RUN update-alternatives --install /usr/bin/java java $JAVA_HOME/bin/java 20000 && update-alternatives --install /usr/bin/javac javac $JAVA_HOME/bin/javac 20000

RUN npm install -g yo bower grunt-cli
RUN npm install -g generator-jhipster

RUN echo 'root:jhipster' |chpasswd
RUN groupadd jhipster && useradd jhipster -s /bin/bash -m -g jhipster -G jhipster && adduser jhipster sudo
RUN echo 'jhipster:jhipster' |chpasswd
RUN mkdir -p /home/jhipster

COPY root/.yo-rc.json /home/jhipster/.yo-rc.json
RUN cd /home && chown -R jhipster:jhipster /home/jhipster

USER jhipster
WORKDIR /home/jhipster
RUN yo jhipster
RUN npm install
RUN grunt test

#ENTRYPOINT ["/usr/local/bin/mvn"]
#CMD ["package", "-Pprod"]
CMD ["bash"]
