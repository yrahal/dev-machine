#!/bin/bash

DIR=`dirname $0`

docker build -t yrahal/dev-machine "$DIR"
