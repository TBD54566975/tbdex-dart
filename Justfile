schemas:
  @git submodule update --init --recursive
  @cp -r tbdex/hosted/json-schemas lib/src/protocol

get:
  #!/bin/bash
  dart pub get

test:
  #!/bin/bash
  dart test

analyze:
  #!/bin/bash
  dart analyze
