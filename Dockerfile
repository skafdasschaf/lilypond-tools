# syntax=docker/dockerfile:1

FROM python:3.9

ENV EES_TOOLS_PATH=/ees-tools
ENV PATH="/root/bin:${PATH}"

WORKDIR /ees

COPY docker .

RUN ./setup.sh

CMD make final/scores
