#!/usr/bin/env bash
if ! output=$(docker-compose run --rm -T aws sts assume-role \
  --role-arn "$AWS_ROLE_ARN" \
  --external-id "$AWS_STS_EXTERNAL_ID" \
  --role-session-name "bloggen-deployment-$(date +%s)" \
  --output json)
then
  >&2 echo "ERROR: Failed to get creds, output: $output"
  exit 1
fi

echo "$output" | \
  jq -r '"AWS_ACCESS_KEY_ID=" + .Credentials.AccessKeyId + " " +
"AWS_SECRET_ACCESS_KEY=" + .Credentials.SecretAccessKey + " " +
"AWS_SESSION_TOKEN=" + .Credentials.SessionToken' | \
  tr ' ' "\n"
