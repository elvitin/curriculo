# syntax=docker/dockerfile:1.7
FROM debian:stable-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  echo "deb http://deb.debian.org/debian stable main" > /etc/apt/sources.list && \
  echo "deb http://deb.debian.org/debian stable-updates main" >> /etc/apt/sources.list && \
  echo "deb http://deb.debian.org/debian-security stable-security main" >> /etc/apt/sources.list && \
  apt-get update && \
  apt-get install -qyf --no-install-recommends \
    texlive-latex-recommended \
    texlive-latex-extra \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-lang-portuguese

WORKDIR /data
VOLUME ["/data"]
