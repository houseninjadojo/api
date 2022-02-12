# Disable the Datadog Agent based on dyno type
if [ "$DYNOTYPE" == "run" ] || [ "$DYNOTYPE" == "scheduler" ] || [ "$DYNOTYPE" == "release" ]; then
  DISABLE_DATADOG_AGENT="true"
fi

# # set datadog.yaml config
# cat << 'EOF' >> "$DATADOG_CONF"

# apm_config:
#   filter_tags:
#     reject: ["outcome:success"]
# EOF