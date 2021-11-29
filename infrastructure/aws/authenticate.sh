#!/usr/bin/env bash
AWS_DOCKER_IMAGE="amazon/aws-cli:2.2.9"
JQ_DOCKER_IMAGE="imega/jq:1.6"
export ENV_FILE="${1?Please provide a dotenv for the AWS authenticator}"
while read -r kv
do
  export "$kv"
done < <(egrep -Ev '^#' "$ENV_FILE" | xargs -0)
if ! output=$(docker run --rm --env-file "$ENV_FILE" "$AWS_DOCKER_IMAGE" sts assume-role \
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
  docker run --rm -i "$JQ_DOCKER_IMAGE" -r '"AWS_ACCESS_KEY_ID=" + .Credentials.AccessKeyId + " " +
"AWS_SECRET_ACCESS_KEY=" + .Credentials.SecretAccessKey + " " +
"AWS_SESSION_TOKEN=" + .Credentials.SessionToken' | \
  tr ' ' "\n"
