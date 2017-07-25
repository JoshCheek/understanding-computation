#!/usr/bin/env bash
node fizzbuzz.js > actual
diff expected actual
