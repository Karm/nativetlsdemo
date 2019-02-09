#!/bin/sh
# @author Michal Karm Babacek

java -server \
 -Xms${TC_MS_HEAP:-64m} \
 -Xmx${TC_MX_HEAP:-512m} \
 -DTC_LOG_LEVEL=${TC_LOG_LEVEL:-FINE} \
 -DTC_CA_CERT_PEM_BASE64=${TC_CA_CERT_PEM_BASE64} \
 -DTC_SERVER_CERT_PEM_BASE64=${TC_SERVER_CERT_PEM_BASE64} \
 -DTC_SERVER_KEY_PEM_BASE64=${TC_SERVER_KEY_PEM_BASE64} \
 -Djava.library.path=/opt/tomcat/tcnative/linux-x86_64 \
 -jar /opt/tomcat/nativetlsdemo.jar
 