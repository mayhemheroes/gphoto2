#Build Stage
FROM --platform=linux/amd64 ubuntu:20.04 as builder

##Install Build Dependencies
RUN apt-get update && \
        DEBIAN_FRONTEND=noninteractive apt-get install -y libpopt-dev libltdl-dev make automake autoconf pkg-config autopoint \
        gettext libtool git gtk-doc-tools libexif-dev libgphoto2-dev

##ADD source code to the build stage
ADD . /gphoto2
WORKDIR /gphoto2

##Build gphoto2
RUN autoreconf -is
RUN ./configure
RUN make -j$(nproc)


FROM --platform=linux/amd64 ubuntu:20.04
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y libgphoto2-6 libgphoto2-port12 libexif12 libreadline8 libpopt0 libltdl7
COPY --from=builder /gphoto2/gphoto2/gphoto2 /gphoto2

RUN mkdir /camera

