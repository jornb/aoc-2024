FROM ubuntu:latest

WORKDIR /io
RUN apt-get update && apt-get install -y wget unzip && apt-get clean
RUN wget http://iobin.suspended-chord.info/linux/iobin-linux-x64-deb-current.zip -O iobin.zip && unzip iobin.zip && rm iobin.zip
RUN dpkg -i ./IoLanguage-*-Linux-x64.deb