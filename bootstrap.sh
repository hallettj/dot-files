#!/bin/sh

sudo apt-get install -y ansible curl git myrepos
mr --trust-all bootstrap https://raw.githubusercontent.com/hallettj/dot-files/master/home/.mrconfig $HOME
