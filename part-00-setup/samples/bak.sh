#!/bin/sh
filepath=$1
cp $filepath $filepath.bak
grep '^[^#$]' $filepath.bak > $filepath
