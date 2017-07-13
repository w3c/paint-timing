#!/bin/bash
set -e # Exit with nonzero exit code if anything fails

bikeshed spec

if [ -d out ]; then
  echo Copy painttiming.html into out/index.html
  cp painttiming.html out/index.html
fi

