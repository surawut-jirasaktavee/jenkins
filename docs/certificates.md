# TLS Configuration to secure the Jenkins server communication over TCP

## Table of Contents

- [TLS Configuration to secure the Jenkins server communication over TCP](#tls-configuration-to-secure-the-jenkins-server-communication-over-tcp)
  - [Table of Contents](#table-of-contents)
  - [Prerequisites](#prerequisites)
  - [Implementation](#implementation)

## Prerequisites

- Docker
- Jenkins Server
- OpenSSL

## Implementation

I will do this under the `certs` directory in the project root. This directory will be mounted to the Jenkins server container.

1. Generate a CA private key and certiificate.

    ```bash
    openssl genrsa -out ca-key.pem 4096
    openssl req -new -x509 -days 365 -key ca-key.pem -sha256 -out ca.pem
    ```

    When running the `openssl req` command, you will be prompted to enter somd information about the certificate. You can leave the fields blank.

2. Create a server key and certificate signing request (CSR).

    ```bash
    openssl genrsa -out server-key.pem 4096
    openssl req -subj "/CN=docker" -sha256 -new -key server-key.pem -out server.csr
    ```

3. Sign the server CSR with the CA private key and certificate.

    ```bash
    openssl x509 -req -days 365 -sha256 -in server.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out server-cert.pem
    ```

4. Create a client key and certificate signing request(CSR).

    ```bash
    openssl genrsa -out key.pem 4096
    openssl req -subj '/CN=client' -new -key key.pem -out client.csr
    ```

5. Sign the client CSR with CA private key and certificate.

    ```bash
    openssl x509 -req -days 365 -sha256 -in client.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out cert.pem
    ```

6. Restrict access to the keys

    ```bash
    chmod -v 0400 ca-key.pem key.pem server-key.pem
    chmod -v 0444 ca.pem server-cert.pem cert.pem
    ```

7. After these steps, you should have the following files in the `certs` directory:

    - `ca-key.pem`: The CA private key
    - `ca.pem`: The CA certificate
    - `server-key.pem`: The server private key
    - `server-cert.pem`: The server certificate
    - `key.pem`: The client private key
    - `cert.pem`: The client certificate

8. Copy the necesary certificates to the `jenkins` directory to mount it to the Jenkins server container.

    ```bash
    mkdir -p certs/jenkins
    cp -v ca-key.pem client.csr key.pem server-cert.pem ./jenkins/
    ```

9. Add the volume mount in the Jenkins service

    ```yaml
    version: "3"
    services:
        jenkins:
            image: premdocker2022/jenkins:2.446
            container_name: jenkins
            ports:
                - 8080:8080 # Jenkins server
                - 50000:50000 # Jenkins agent
            volumes:
                - ./jenkins:/var/jenkins_home
                - ./certs/jenkins:/certs/client:ro # mounted the certificate files to the Jenkins server in read-only mode
            networks:
                - jenkins-net
            environment:
                - DOCKER_TLS_VERIFY=1 # enable TLS verification
                - DOCKER_CERT_PATH=/certs/client # path to client certs
                - DOCKER_HOST=tcp://docker:2376 # docker host
            restart: on-failure
    ```

    NOTE: The `Jenkin Agent`  service will do not have the volume mount for the certificates. The Jenkins server will handle the communication with the Docker daemon via the unix socket directly by the volume mount `/var/run/docker.sock:/var/run/docker.sock`.
