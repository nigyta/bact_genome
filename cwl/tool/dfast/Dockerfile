# base image
FROM quay.io/biocontainers/dfast:1.2.4--py37h8b12597_0

MAINTAINER nigyta


RUN /usr/local/opt/dfast-1.2.4/scripts/reference_util.py formatdb -i /usr/local/opt/dfast-1.2.4/db/protein/DFAST-default.ref ; /usr/local/opt/dfast-1.2.4/scripts/reference_util.py formathmm -i /usr/local/opt/dfast-1.2.4/db/hmm/TIGRFAMs_15.0_HMM.LIB 

