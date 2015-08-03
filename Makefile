.PHONY: box test

box:
	cd box && bash build.sh

test:
	bash test.sh