FROM --platform=$BUILDPLATFORM ghcr.io/houseninjadojo/api-base:latest AS Builder
FROM --platform=$BUILDPLATFORM ghcr.io/houseninjadojo/api-intermediate:latest

LABEL org.opencontainers.image.source="https://github.com/houseninjadojo/api"
LABEL org.opencontainers.image.description="House Ninja API"
LABEL org.opencontainers.image.authors="House Ninja Engineering <engineering@houseninja.co>"
LABEL org.opencontainers.image.vendor="House Ninja"

# Workaround to trigger Builder's ONBUILDs to finish:
# COPY --from=Builder /etc/alpine-release /tmp/dummy
# workaround to trigger Builder's ONBUILDs to finish:
COPY --from=Builder /etc/passwd /etc/passwd_builder 

# USER app
CMD ["bin/rails", "server"]
