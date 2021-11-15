# syntax=docker/dockerfile:1

FROM python:3.9

ENV EES_TOOLS_PATH=/ees-tools
ENV PATH="/root/bin:${PATH}"

WORKDIR /ees

COPY docker .
COPY add_variables.py \
     ees.ly \
     ees.mk \
     instrument_data.csv \
     make_works_table.py \
     read_metadata.py \
     /ees-tools/

RUN ./setup.sh

CMD make final/scores
