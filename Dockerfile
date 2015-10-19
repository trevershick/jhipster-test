# Ubuntu 14.04 LTS
# Oracle Java 1.8.0_11 64 bit
# Maven 3.2.2
# git 1.9.1

# originally from stephenreed/jenkins-java8-maven-git
FROM ubuntu:14.04

MAINTAINER Trever M. Shick (http://shick.io, trever@shick.io)

# this is a non-interactive automated build - avoid some warning messages
ENV DEBIAN_FRONTEND noninteractive

# update dpkg repositories
RUN apt-get update

# install wget
RUN apt-get install -y wget

# get maven 3.2.2
RUN wget --no-verbose -O /tmp/apache-maven-3.2.2.tar.gz http://archive.apache.org/dist/maven/maven-3/3.2.2/binaries/apache-maven-3.2.2-bin.tar.gz

# verify checksum
RUN echo "87e5cc81bc4ab9b83986b3e77e6b3095 /tmp/apache-maven-3.2.2.tar.gz" | md5sum -c

# install maven
RUN tar xzf /tmp/apache-maven-3.2.2.tar.gz -C /opt/
RUN ln -s /opt/apache-maven-3.2.2 /opt/maven
RUN ln -s /opt/maven/bin/mvn /usr/local/bin
RUN rm -f /tmp/apache-maven-3.2.2.tar.gz
ENV MAVEN_HOME /opt/maven

# install git
RUN apt-get install -y git

RUN apt-get install mysql-server-5.6
#install nodejs
RUN apt-get install -y nodejs npm

# remove download archive files
RUN apt-get clean

# set shell variables for java installation
ENV java_version 1.8.0_11
ENV filename jdk-8u11-linux-x64.tar.gz
ENV downloadlink http://download.oracle.com/otn-pub/java/jdk/8u11-b12/$filename

# download java, accepting the license agreement
RUN wget --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" -O /tmp/$filename $downloadlink

# unpack java
RUN mkdir /opt/java-oracle && tar -zxf /tmp/$filename -C /opt/java-oracle/
ENV JAVA_HOME /opt/java-oracle/jdk$java_version
ENV PATH $JAVA_HOME/bin:$PATH

# configure symbolic links for the java and javac executables
RUN update-alternatives --install /usr/bin/java java $JAVA_HOME/bin/java 20000 && update-alternatives --install /usr/bin/javac javac $JAVA_HOME/bin/javac 20000

# copy jenkins war file to the container
# ADD http://mirrors.jenkins-ci.org/war/1.574/jenkins.war /opt/jenkins.war
# RUN chmod 644 /opt/jenkins.war
# ENV JENKINS_HOME /jenkins

# configure the container to run jenkins, mapping container port 8080 to that host port
# EXPOSE 8080


RUN npm install -g yo bower grunt-cli
RUN npm install -g generator-jhipster@2.22.0

MKDIR /var/jhipster-test
WORKDIR /var/jhipster-test
COPY root/.yo-rc.json /var/jhipster-test/.yo-rc.json
RUN yo jhipster
RUN grunt test

ENTRYPOINT ["/usr/local/bin/mvn"]
CMD ["package", "-Pprod"]
