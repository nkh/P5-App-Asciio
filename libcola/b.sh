#!/bin/bash

g++ -std=c++17 layout.cpp \
    -lcola -lavoid -lvpsc \
    -Ijson/include -I/home/nadim/nadim/devel/repositories/adaptagrams/cola \
    -o layout
