#Build Stage
FROM --platform=linux/amd64 ubuntu:20.04 as builder

##Install Build Dependencies
RUN apt-get update && \
        DEBIAN_FRONTEND=noninteractive apt-get install -y make pkg-config libpopt-dev libgphoto2-dev build-essential git autoconf automake autopoint libtool

##ADD source code to the build stage
WORKDIR /
ADD https://api.github.com/repos/ennamarie19/gphoto2/git/refs/heads/mayhem version.json
RUN git clone -b mayhem https://github.com/ennamarie19/gphoto2.git
WORKDIR /gphoto2

##Build
RUN autoreconf -is
RUN ./configure
RUN make -j$(nproc)

##Prepare all library dependencies for copy
RUN mkdir /deps
RUN cp `ldd ./gphoto2/gphoto2 | grep so | sed -e '/^[^\t]/ d' | sed -e 's/\t//' | sed -e 's/.*=..//' | sed -e 's/ (0.*)//' | sort | uniq` /deps 2>/dev/null || : 

FROM --platform=linux/amd64 ubuntu:20.04
COPY --from=builder /gphoto2/gphoto2/gphoto2 /gphoto2
COPY --from=builder /deps /usr/lib
#copy from deps on old system to usrLib on new system

CMD ["/gphoto2", "--hook-script=@@"]

