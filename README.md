# Tomcat Embedded with NIO + OpenSSL

Tomcat Embedded in this demo uses Tomcat Native binary built for Linux x86_64 to
accelerate crypto operations. The binary depends on APR and OpenSSL that could be
easily installed on the host system (container).

Once started, it just shows three fire emojis 🔥🔥🔥 on https://localhost:8443.

## Current state

Tomcat Native binary is looked up in ```-Djava.library.path=./tcnative/linux-x86_64```. It needs OpenSSL 1.0.2+
and APR 1.4+, but it is tightly coupled with a particular Tomcat version. We know that this particular Tomcat Native 1.2.21
works with Tomcat 9.0.16, yet this knowledge is not kept in Maven as Maven packaging knows noting about the binary.
Only the Java Tomcat Embedded library is defined in our pom.xml:

```
    <properties>
        <version.tomcat>9.0.16</version.tomcat>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.apache.tomcat.embed</groupId>
            <artifactId>tomcat-embed-core</artifactId>
            <version>${version.tomcat}</version>
            <type>jar</type>
        </dependency>
    </dependencies>
```

## Desired status

It would be beneficial for ordinary users of Tomcat Embedded to be able to get accelerated crypto with Tomcat Embedded
via Tomcat Native just by defining a dependency in their pom.xml such as:

```
    <properties>
        <version.tomcat>9.0.16</version.tomcat>
        <version.tomcat.native>1.2.21</version.tomcat.native>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.apache.tomcat.embed</groupId>
            <artifactId>tomcat-embed-core</artifactId>
            <version>${version.tomcat}</version>
            <type>jar</type>
        </dependency>
        <dependency>
            <groupId>org.apache.tomcat.embed</groupId>
            <artifactId>tcnative-linux-x86_64</artifactId>
            <version>${version.tomcat.native}</version>
        </dependency
    </dependencies>
```

It is possible to package native libraries within Jar files and have them loaded with a little bit of Reflection.
A very simple, tiny project that does this is native CRC64 implementation packaged for Java: [CRC64Java](https://github.com/Karm/CRC64Java).
A bigger project utilizing the approach is [wildfly-openssl](https://github.com/wildfly/wildfly-openssl).


There already has been some initial effort to achieve this, tracked on [JWS-855](https://issues.jboss.org/browse/JWS-855), namely [JWS-855.patch](https://issues.jboss.org/secure/attachment/12438145/JWS-855.patch) and [native.jar](https://issues.jboss.org/secure/attachment/12438146/native.jar).


# Building and running

## Requirements

 * OpenJDK 11
 * Maven 3.5.2+
 * OpenSSL
 * APR (Apache Portable Runtime)
 * Docker engine

# Running locally on Fedora/Centos
or a similar modern Linux with OpenSSL and APR installed:

```
mvn package && \
java -Djava.library.path=./tcnative/linux-x86_64/ \
     -DTC_CA_CERT_PEM_BASE64=`base64 -w0 democerts/ca/certs/ca.cert.pem` \
     -DTC_SERVER_CERT_PEM_BASE64=`base64 -w0 democerts/server/certs/server.cert.pem` \
     -DTC_SERVER_KEY_PEM_BASE64=`base64 -w0 democerts/server/private/server.key.nopass.pem` \
-jar target/nativetlsdemo.jar
```

# Running Docker build

```
mvn package
docker build -t karm/nativetlsdemo:1.0-SNAPSHOT .
```

# Running Docker container

```
docker run  -e TC_CA_CERT_PEM_BASE64=`base64 -w0 democerts/ca/certs/ca.cert.pem` \
            -e TC_SERVER_CERT_PEM_BASE64=`base64 -w0 democerts/server/certs/server.cert.pem` \
            -e TC_SERVER_KEY_PEM_BASE64=`base64 -w0 democerts/server/private/server.key.nopass.pem` \
            -p 127.0.0.1:8443:8443/tcp -d -i --name nativetlsdemo karm/nativetlsdemo:1.0-SNAPSHOT
```

See logs:

```
docker logs -f nativetlsdemo
```

See app:

Either import the CA in your browser or accept exception: https://localhost:8443
