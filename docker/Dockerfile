FROM ghcr.io/armmbed/mbed-os-env:mbed-os-6-latest
WORKDIR /
RUN apt-get update ; apt-get -y install jq rsync
ADD . /arduino/ArduinoCore-mbed
COPY ./docker/build.sh /arduino/build.sh
RUN chmod +x /arduino/build.sh
WORKDIR /arduino/ArduinoCore-mbed
CMD [ "/arduino/build.sh" ]
