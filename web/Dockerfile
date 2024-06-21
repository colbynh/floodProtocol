FROM python:3

LABEL maintainer="Guitaristcolby@gmail.com"

RUN apt-get update -y && \
    apt-get install -y python3-pip && \
    apt-get install -y curl && \
    apt-get install -y jq


COPY . /web

COPY ./requirements.txt /web/requirements.txt

WORKDIR /web

RUN pip3 install -r requirements.txt

ENTRYPOINT [ "python3" ]

CMD [ "app.py" ]