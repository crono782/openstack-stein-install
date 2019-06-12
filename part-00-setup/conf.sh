#!/bin/bash
file=$1
section=$2
key=$3
shift;shift;shift
value="$@"
if [ "$(grep -c "^\[$section\]" $file)" -lt 1  ]; then
  echo [$section] >> $file
fi
if [ ! -z "$(sed -n "/\[$section\]/,/\[/{/^$key =.*/=}" $file)" ]; then
  sed -i "/\[$section\]/,/\[/{s/$key[ =].*/$key = $value/}" $file
else
  sed -i "/^\[$section\]/a $key = $value" $file
fi
