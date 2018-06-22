FROM ubuntu:16.04

ARG ERLANG_VERSION=21.0
ARG ELIXIR_VERSION=1.6.6

SHELL ["/bin/bash", "-c"]
RUN apt-get update && \
apt-get install --yes locales && \
locale-gen en_US.UTF-8
ENV LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 LANGUAGE=en_US:en

RUN apt-get install --yes wget unzip build-essential apt-transport-https

RUN source /etc/lsb-release && \
echo "deb https://packages.erlang-solutions.com/ubuntu $DISTRIB_CODENAME contrib" >> /etc/apt/sources.list && \
cat /etc/apt/sources.list && \
wget --quiet -O - https://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc | apt-key add - && \
apt-get update && \
apt-get install --yes erlang=1:$ERLANG_VERSION-1

RUN wget https://github.com/elixir-lang/elixir/releases/download/v$ELIXIR_VERSION/Precompiled.zip && \
unzip -d /usr/local Precompiled.zip && \
rm Precompiled.zip

WORKDIR project

COPY mix.exs mix.lock ./

ENV MIX_ENV=prod

RUN mix local.hex --force && \
mix local.rebar --force && \
mix deps.get && \
mix deps.compile

COPY config config/
COPY lib lib/
COPY priv priv/
COPY rel rel/

CMD echo "Building release for the \"$MIX_ENV\" environment" && \
mix do compile, release && \
cp _build/$MIX_ENV/rel/*/releases/*/*.tar.gz /release/ && \
echo "Done"
