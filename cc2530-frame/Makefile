build:	isolated

isolated:
	mkdir -p .gopath/src/github.com/ninjasphere && \
	ln -sf ../../../../../../zigbee-zstack-gateway .gopath/src/github.com/ninjasphere && \
	cd .gopath/src/github.com/ninjasphere/zigbee-zstack-gateway/cc2530-frame && \
	GOPATH=$(PWD)/.gopath make here

here: 
	mkdir -p bin
	go get -d ./...
	go build -o bin/cc2530-frame

fmt:
	gofmt -s -w *.go

clean:
	-rm bin/*
	-rm -rf .gopath
