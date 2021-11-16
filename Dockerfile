# syntax=docker/dockerfile:1

FROM python:3.9

ENV EES_TOOLS_PATH=/ees-tools
ENV PATH="/root/bin:${PATH}"

WORKDIR /ees

COPY docker .
COPY *.py \
     *.ly \
     *.mk \
     instrument_data.csv \
     /ees-tools/
COPY tex/latex/*.cls  \
     tex/latex/*.pdf \
     /ees-tools/tex/latex/

RUN ./setup.sh

CMD make final/scores
