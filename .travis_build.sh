#!/bin/bash

cmake --build ./build > log || cat log
