# base image
FROM ubuntu:18.04

MAINTAINER nigyta


RUN apt-get update; apt-get install -y curl libgomp1; curl -L http://platanus.bio.titech.ac.jp/?ddownload=403  -o  platanus.tar.gz; tar xvfz platanus.tar.gz; cp ./Platanus_B_*_Linux_x86_64_bin/platanus_b /usr/local/bin/ ; rm -rf platanus.tar.gz Platanus_B_* ;  apt-get clean
