FROM python:3.11-slim

WORKDIR /opt/spcs
COPY ./main.sh /opt/spcs/
COPY ./requirements.txt /opt/spcs/cfg/

RUN apt-get update -y
RUN apt-get install python3-pip -y
RUN pip3 install --upgrade pip
RUN pip3 install --no-cache-dir --upgrade -r ./cfg/requirements.txt
#RUN pip3 uninstall oscrypto -y
#RUN pip3 install -force-reinstall https://github.com/wbond/oscrypto/archive/d5f3437ed24257895ae1edd9e503cfb352e635a8.zip

RUN chmod 744 /opt/spcs/main.sh
ENTRYPOINT [ "/opt/spcs/main.sh" ]
EXPOSE 80 