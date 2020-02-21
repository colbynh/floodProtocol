FROM ubuntu:16.04

LABEL maintainer="Guitaristcolby@gmail.com"

RUN apt-get update -y && \
    apt-get install -y python-pip python-dev

COPY ./requirements.txt /web/requirements.txt

WORKDIR /web

RUN pip install -r requirements.txt

COPY . /web

ENTRYPOINT [ "python" ]

CMD [ "app.py" ]