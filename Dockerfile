ARG WHEELS=/wheels

FROM python:3.11-bullseye as builder
ARG WHEELS
ENV PYTHONUNBUFFERED=1
ENV LC_ALL C
ENV LANG C
ENV LANGUAGE C

RUN apt-get update && \
    apt-get install -y \
	build-essential \
	cmake

RUN python -m pip install -U pip wheel
COPY --from=ghcr.io/mkocot/docker-numpy:master ${WHEELS} ${WHEELS}
RUN python -m pip install --no-index --find-links ${WHEELS} numpy && \
    pip wheel --no-cache-dir -w ${WHEELS} 'matplotlib==3.7.2'

FROM scratch
ARG WHEELS
COPY --from=builder ${WHEELS} ${WHEELS}
