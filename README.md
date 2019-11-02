# automated-reasoner-builds

This repository provides tooling to easily build automated reasoning tools using
Docker. The package builds statically linked binaries using a Dockerfile that
provides the relevant dependencies. Furthermore, the build logs are stored, in
case it needs to be accessed for debugging purposes.

# Example Calls

The following call builds all available tools, i.e. builds all scripts that
match the pattern ./building/build-$TOOL.sh:

```
./building/build-tools.sh
```

The following example allows to only build the tool "mergesat"

```
DOCKER_BUILD_TARGET=mergesat ./building/build-tools.sh
```
