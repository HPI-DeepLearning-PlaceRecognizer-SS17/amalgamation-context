#!/bin/bash

# Creates a docker container that contains a repeatable environment for mxnet amalgamation
docker build -t amalgamation-buildcontext .

docker run -v "C:\Users\Arthur Silber\Documents\Studium\Master\Semester 3\Practical Video Analysis\mxnet:/mxnet" \
	-e "MXNET_ROOT=/mxnet"
	-ti --rm amalgamation-buildcontext bash
