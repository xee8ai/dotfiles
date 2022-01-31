#!/bin/bash

aptitude search -t $(lsb_release -sc)-backports '~U ~Abackports'
echo
echo "Hint: Install using"
echo "apt-get install <package>/bullseye-backports or"
echo "apt-get install -t bullseye-backports <package>"
echo
