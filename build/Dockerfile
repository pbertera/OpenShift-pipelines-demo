FROM ubi8:latest

WORKDIR /opt/data

RUN dnf install -y python3-pip git &&\
    pip3 install mkdocs mkdocs-material

EXPOSE ["8000"]

ENTRYPOINT ["mkdocs"]
