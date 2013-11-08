#!/bin/bash

# 	      graphite,         carbon/plaintext,    carbon/pickle, query cache, statsd

docker run -p=8080:8080 -p=2003:2003/udp -p=2003:2003 -p=2004:2004 -p=8125:8125/udp -p=8125:8125 -d mattbaird/statsd-graphite
