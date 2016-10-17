FROM elixir:1.3

WORKDIR /opt/hitchcock

# Get Postgres libraries for Ecto
RUN apt-get -yq update && \
    apt-get -yq install --no-install-recommends \
        libpq-dev \
        postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Get deps
COPY mix.exs mix.lock /opt/hitchcock/
RUN yes | mix deps.get

# Build api
COPY ./ /opt/hitchcock
RUN mix local.rebar && mix compile --long-compilation-threshold 40

ENTRYPOINT ["mix", "phoenix.server"]
