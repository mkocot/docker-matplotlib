ARG MATPLOTLIB_VERSION=3.7.2
ARG WHEELS=/wheels

FROM docker.io/python:3.11-bullseye as builder
ARG WHEELS
ARG MATPLOTLIB_VERSION
ENV PYTHONUNBUFFERED=1
ENV LC_ALL C
ENV LANG C
ENV LANGUAGE C

RUN apt-get update && \
    apt-get install -y \
	build-essential \
	cmake

RUN python -m pip install -U pip wheel

COPY --from=ghcr.io/mkocot/docker-numpy:latest ${WHEELS} ${WHEELS}

# NOTE: Force usage of binary numpy from my build or pypi index.
#	This fixes issue where matplotlib would fetch new release and
#	would start building numpy package without required libs
RUN python -m pip install --no-index --find-links ${WHEELS} numpy && \
    python -m pip wheel --no-cache-dir --wheel-dir ${WHEELS} \
	    --only-binary 'numpy' \
	    "matplotlib==${MATPLOTLIB_VERSION}"

FROM scratch
ARG WHEELS
COPY --from=builder ${WHEELS} ${WHEELS}
