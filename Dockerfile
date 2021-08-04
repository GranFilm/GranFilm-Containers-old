FROM gcc:9.4.0

LABEL Sunniva Indrehus <sunniva.indrehus@gmail.com>

ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

# Create folders 
RUN mkdir -p ${HOME}/usr/src && \ 
    mkdir -p ${HOME}/usr/lib/gcc/9.4.0/OpenBLAS && \
    mkdir -p ${HOME}/usr/lib64 && \
    mkdir -p ${HOME}/GranFilm

# Add local folders to the image 
COPY ./src ${HOME}/usr/src 

COPY ./GranFilm ${HOME}/GranFilm

# # Build OpenBLAS 
RUN cd ${HOME}/usr/src/OpenBLAS && \ 
    make && \ 
    make PREFIX=${HOME}/usr/lib/gcc/9.4.0/OpenBLAS install 

# # Symbolic links for the compilation process
# #RUN ln -s /usr/local/lib/gcc/9.4.0/Slatec41E/libSlatec41E.a /usr/local/bin/libSlatec41E.a && \
RUN ln -s ${HOME}/usr/lib/gcc/9.4.0/OpenBLAS/lib/libopenblas.a ${HOME}/usr/lib64/libopenblas.a && \
    ln -s ${HOME}/usr/lib/gcc/9.4.0/OpenBLAS/lib/libopenblas.so ${HOME}/usr/lib64/libopenblas.so && \
    ln -s ${HOME}/usr/lib/gcc/9.4.0/OpenBLAS/lib/libopenblas.so.0 /usr/lib/libopenblas.so.0


# Install dependencies for the dependencies of the building process
RUN apt-get update && apt-get -y update


RUN apt-get install -y makedepf90   

RUN cd ${HOME}/GranFilm/granfilm/Src && \ 
    make clean && \
    make all && \ 
    cp GranFilm ${HOME}/GranFilm/granfilmpy/bin/    

RUN apt-get -y install python3-pip
 
ADD ./GranFilm/granfilmpy/requirements.txt .
RUN pip3 install -r requirements.txt

CMD ["/bin/bash", "-l"]


# Make sure the contents of our repo are in ${HOME}
COPY . ${HOME}
USER root
RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}
