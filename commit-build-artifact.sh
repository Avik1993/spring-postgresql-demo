#!/bin/sh

# build and deploy new jar artifact to the github repository
# jar is then pulled by dockerfile during docker build

#sh ./commit-build-artifact.sh

set -xe

./gradlew clean build

cd build/libs

git init
git add *.jar
git commit -m "Deploy JAR build artifacts to GitHub"
git push --force --quiet "git@github.com:garystafford/spring-postgresql-demo.git" master:build-artifacts-gke
