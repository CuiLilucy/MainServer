#!/bin/bash
cat $1 | base64 -w0 > .test.base64
cd backend
ecs test.ecs ../.test.base64
