FROM elixir:1.3

WORKDIR /opt/

# Get Postgres libraries for Ecto
RUN apt-get -yq update && \
    apt-get -yq install --no-install-recommends \
        inotify-tools \
        libpq-dev \
        postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Get deps
COPY mix.exs /opt/

RUN  mix local.hex --force && mix hex.info

ONBUILD RUN yes | mix deps.get \
	&& mix local.rebar \
	&& mix compile --long-compilation-threshold 40

ENTRYPOINT ["mix", "phoenix.server"]
