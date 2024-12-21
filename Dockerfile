FROM rust:1.83-slim-bookworm AS builder

RUN apt-get update -y && apt-get install -y git musl-dev build-essential cmake && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*

WORKDIR /app

RUN mkdir -p /app/bin && \
    cd /app && \
    git clone https://github.com/harlanc/xiu.git --depth 1 src && \
    cd src/confs && \
    sh ./update_project_conf.sh local

RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/app/src/target \
    cd src/application/xiu && cargo build --release && cp /app/src/target/release/xiu /app/bin/xiu

FROM debian:bookworm-slim

RUN apt-get update -y && apt-get install -y ffmpeg && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*

WORKDIR /app

COPY --from=builder /app/bin/xiu /app/bin/xiu

EXPOSE 1935
EXPOSE 8000
EXPOSE 8080

# docker run -it --rm xiu 
ENTRYPOINT ["/app/bin/xiu"]
CMD ["--config", "/app/etc/config.toml"]
