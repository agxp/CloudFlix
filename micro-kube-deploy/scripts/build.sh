#!/bin/bash

set -e
set -x

REGISTRY=microhq
TAG=kubernetes

# Used to rebuild all the things

build() {
	local dir=$1

	if [ -z "$dir" ] || [ ! -d "$dir" ]; then
		return
	fi

	if [ ! -f $dir/Dockerfile ]; then
		return
	fi

	if [ -f $dir/.skip ]; then
		return
	fi

	pushd $dir >/dev/null

	# test
	go test -v ./...

	# build static binary
	CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags '-w' -o $dir ./main.go

	# build docker image
	docker build -t $REGISTRY/$dir:$TAG .

	# push docker image
	docker push $REGISTRY/$dir:$TAG

	# remove binary
	rm $dir

	popd >/dev/null
}

pushd cmd >/dev/null

# build specified dir
if [ -n "$1" ]; then
	build $1
	popd >/dev/null
	exit $?
fi


# build all the things
find * -type d -maxdepth 0 -print | while read dir; do
	build "$dir"

done

popd >/dev/null

