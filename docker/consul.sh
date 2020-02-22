#!/bin/bash

docker run -d --name=consul -p 8300-8302:8300-8302 -p 8500:8500 -p 8600:8600 consul:latest