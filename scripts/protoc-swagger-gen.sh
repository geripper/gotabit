#!/usr/bin/env bash

set -eo pipefail

mkdir -p ./tmp-swagger-gen
cd proto
proto_dirs=$(find ./gotabit -path -prune -o -name '*.proto' -print0 | xargs -0 -n1 dirname | sort | uniq)
for dir in $proto_dirs; do
  # generate swagger files (filter query files)
  query_file=$(find "${dir}" -maxdepth 1 \( -name 'query.proto' -o -name 'service.proto' \))
  if [[ ! -z "$query_file" ]]; then
    buf generate --template buf.gen.swagger.yaml $query_file
  fi
done
cd ..

cd third_party
proto_dirs=$(find ./proto -path -prune -o -name '*.proto' -print0 | xargs -0 -n1 dirname | sort | uniq)
for dir in $proto_dirs; do
  # generate swagger files (filter query files)
  query_file=$(find "${dir}" -maxdepth 1 \( -name 'query.proto' -o -name 'service.proto' \))
  if [[ ! -z "$query_file" ]]; then
    buf generate --template buf.gen.swagger.yaml $query_file
  fi
done

cd ../client/docs

yarn install
yarn combine
yarn convert
yarn build

cd ../../

rm -rf ./tmp-swagger-gen

# generate binary for static server
statik -src=client/docs/static -dest=client/docs -f -m
