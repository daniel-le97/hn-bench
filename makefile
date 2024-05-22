# Set the virtual environment directory
MODS_DIR = node-nuke-test

ARGS = $(filter-out $@,$(MAKECMDGOALS))
# Activate the virtual environment


build:
	v v.v -prod
	go build go.go
	bun build ./bun.ts --compile --outfile=bun_app
	cd rust && cargo build --release

run:
	make v
	make go
	make bun
	make ruster
	make bash

v:
	time ./v

go: 
	time ./go

ruster:
	cd rust && time ./target/release/rust

bun:
	time ./bun_app

bash:
	time bash bash.sh

# Prevent make from trying to use these as file targets
%:
	@:
