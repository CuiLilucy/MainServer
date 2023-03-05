#!/bin/bash
cat /workspace/upload/images/$1 | base64 -d > /workspace/upload/images/$1.bin
cd /workspace/upload/
python server.py /workspace/upload/images/$1.bin
