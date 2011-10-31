GEM = pkg/stringglob-0.0.2.gem

default: build

build: gem

gem:
	rake build

upload:
	 gem push $(GEM)

