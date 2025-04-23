#!/bin/sh

GS_VERSION="$(ghostscript --version | awk '{print $1}')"
GS_LIB="$SNAP/usr/share/ghostscript/$GS_VERSION/Resource/Init"

exec $@