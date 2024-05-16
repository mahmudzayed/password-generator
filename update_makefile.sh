#!/bin/bash

# This script simply updates the Makefile for major changes, like version update.

APP_VERSION=$(head -1 version.txt)
sed -Ei "s/(^IMAGE_TAG=\")(.*)(\")/\1${APP_VERSION}\3/g" ./app/Makefile