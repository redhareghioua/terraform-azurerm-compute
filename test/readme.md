## Modules Compute

This modules creates a vm with
- nic
- nsg
- disk encryption

See the [tests](./test/fixtures/main.tf) as an example on how to use the module.

## Execute the Tests

### Install Golang 1.14.4

```bash
wget https://storage.googleapis.com/golang/go1.14.4.linux-amd64.tar.gz
sudo tar -xzf go1.14.4.linux-amd64.tar.gz -C /usr/local
```

if required (command 'go' not found):
```bash
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
```

### Run the tests

From this folder, run :
go get -t -d -v ./...

1. In the test folder, run 'dep ensure'
2. Once that finishes, run 'go test -v' 
