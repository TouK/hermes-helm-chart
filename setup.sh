#!/bin/sh

set -e

helm repo add touk https://helm-charts.touk.pl/public/
helm dependencies build src