#!/bin/sh

sudo apt-get install ansible curl git myrepos
mr bootstrap https://raw.githubusercontent.com/hallettj/dot-files/master/home/.mrconfig $HOME
