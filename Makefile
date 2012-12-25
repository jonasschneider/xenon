go: test build hup

hup:
	ps -Af|grep node|grep xenon| grep -v while| cut -d " " -f 4|xargs kill -HUP

test:
	cd src && NODE_PATH=. ../node_modules/jasmine-node/bin/jasmine-node --coffee ../spec

serve: build
	# directly run it like this so we don't get the RequireJS-wrapped version
	true; while [ $$? = 0 ]; do node_modules/coffee-script/bin/coffee src/server-main.coffee --xenon; done

build:
	mkdir -p compiled
	rm -fr compiled/*
	cp -r vendor/* compiled
	node_modules/coffee-script/bin/coffee -c -o compiled src
	node vendor/r -convert compiled compiled

shrink:
	node ~/r.js -o client/buildconfig.js

dev:
	node_modules/coffee-script/bin/coffee --watch --compile -o compiled src
