schemas:
  @git submodule update --init --recursive
  @cp -r tbdex/hosted/json-schemas lib/src/protocol

get:
  @dart pub get

test:
  @dart test

analyze:
  @dart analyze
