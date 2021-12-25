FROM --platform=$BUILDPLATFORM ghcr.io/houseninjadojo/api-base:latest AS Builder
FROM --platform=$BUILDPLATFORM ghcr.io/houseninjadojo/api-intermediate:latest

LABEL org.opencontainers.image.source https://github.com/houseninjadojo/api

# Workaround to trigger Builder's ONBUILDs to finish:
# COPY --from=Builder /etc/alpine-release /tmp/dummy
# workaround to trigger Builder's ONBUILDs to finish:
COPY --from=Builder /etc/passwd /etc/passwd_builder 

# USER app
CMD ["bundle", "exec", "rails", "server"]
