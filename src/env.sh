if [ -z "$S3_BUCKET" ]; then
  echo "You need to set the S3_BUCKET environment variable."
  exit 1
fi

if [ -z "$POSTGRESQL_DATABASE" ]; then
  echo "You need to set the POSTGRESQL_DATABASE environment variable."
  exit 1
fi

if [ -z "$POSTGRESQL_HOST" ]; then
  # https://docs.docker.com/network/links/#environment-variables
  if [ -n "$POSTGRES_PORT_5432_TCP_ADDR" ]; then
    POSTGRESQL_HOST=$POSTGRES_PORT_5432_TCP_ADDR
    POSTGRESQL_PORT=$POSTGRES_PORT_5432_TCP_PORT
  else
    echo "You need to set the POSTGRESQL_HOST environment variable."
    exit 1
  fi
fi

if [ -z "$POSTGRESQL_USER" ]; then
  echo "You need to set the POSTGRESQL_USER environment variable."
  exit 1
fi

if [ -z "$POSTGRESQL_PASSWORD" ]; then
  echo "You need to set the POSTGRESQL_PASSWORD environment variable."
  exit 1
fi

if [ -z "$S3_ENDPOINT" ]; then
  aws_args=""
else
  aws_args="--endpoint-url $S3_ENDPOINT"
fi


if [ -n "$S3_ACCESS_KEY_ID" ]; then
  export AWS_ACCESS_KEY_ID=$S3_ACCESS_KEY_ID
fi
if [ -n "$S3_SECRET_ACCESS_KEY" ]; then
  export AWS_SECRET_ACCESS_KEY=$S3_SECRET_ACCESS_KEY
fi
export AWS_DEFAULT_REGION=$S3_REGION
export PGPASSWORD=$POSTGRESQL_PASSWORD
