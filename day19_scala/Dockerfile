FROM openjdk:25-slim

WORKDIR /scala
RUN apt-get update && apt-get install -y curl && apt-get clean
RUN curl -fL https://github.com/coursier/coursier/releases/latest/download/cs-x86_64-pc-linux.gz | gzip -d > cs && chmod +x cs && ./cs setup --yes
RUN echo '#!/bin/bash'>run
RUN echo '/root/.local/share/coursier/bin/scala run "$1"'>>run
RUN chmod +x run
RUN echo '@main def hello() = println("Hello, World!")'>hello.scala
RUN ./run hello.scala
