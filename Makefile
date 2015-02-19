install:
	make clean \
	&& npm install \
	&& gem install bundler \
	&& bundle install \
	&& powder link

clean:
	rm -rf ./node_modules \
	&& rm -rf ./public \
	&& rm -rf ./tmp \
	&& rm -rf ./sass-cache

update:
	npm update
	&& bundle update

deploy:
	gulp release \
	&& s3_website push

release:
	gulp release

build:
	gulp cleanbuild

watch:
	gulp

open:
	powder open