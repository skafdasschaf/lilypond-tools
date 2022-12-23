# syntax=docker/dockerfile:1

FROM python:3.11

ARG user_id
ARG group_id

ENV EES_TOOLS_PATH=/opt/ees-tools
ENV PATH="/root/bin:/opt/lilypond/bin:${PATH}"

WORKDIR /ees

COPY docker .

RUN ./setup.sh

CMD make final/scores
