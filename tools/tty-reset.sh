#!/usr/bin/env bash

tools=$(dirname "$0")

#issue a reset
$tools/cc2530-frame 41 00 00
