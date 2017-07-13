#!/bin/bash
set -e # Exit with nonzero exit code if anything fails

bikeshed spec

if [ -d out ]; then
  echo Copy the generated spec into out/index.html
  cp painttiming.html out/index.html

  echo Copying images into out/
  cp filmstrip.svg filmstrip.png out/
fi
