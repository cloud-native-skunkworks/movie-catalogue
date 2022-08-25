#!/bin/bash
oapi-codegen --package api --old-config-style --generate "types,server,spec" swagger.yaml > pkg/apiserver.generated.go
