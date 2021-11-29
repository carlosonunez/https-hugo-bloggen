#!/usr/bin/env bash
while read -r kv
do
  export "$kv"
done < <(egrep -Ev '^#' "$1" | xargs -0)
env | grep AWS
if ! output=$(docker-compose run --rm -T aws sts assume-role \
  --role-arn "$AWS_ROLE_ARN" \
  --external-id "$AWS_STS_EXTERNAL_ID" \
  --role-session-name "bloggen-deployment-$(date +%s)" \
  --output json)
then
  >&2 echo "ERROR: Failed to get creds, output: $output"
  exit 1
fi
>&2 echo "DEBUG: got output: $output"

echo "$output" | \
  jq -r '"AWS_ACCESS_KEY_ID=" + .Credentials.AccessKeyId + " " +
"AWS_SECRET_ACCESS_KEY=" + .Credentials.SecretAccessKey + " " +
"AWS_SESSION_TOKEN=" + .Credentials.SessionToken' | \
  tr ' ' "\n"
