FROM tomcat:8-jre11

RUN rm -rf /usr/local/tomcat/webapps/*

COPY target/Jenkins-v3.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 80
CMD ["catalina.sh", "run"]
