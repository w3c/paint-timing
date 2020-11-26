SHELL=/bin/bash

local: painttiming.bs
	bikeshed --die-on=warning spec painttiming.bs painttiming.html

painttiming.html: painttiming.bs
	@ (HTTP_STATUS=$$(curl https://api.csswg.org/bikeshed/ \
	                       --output painttiming.html \
	                       --write-out "%{http_code}" \
	                       --header "Accept: text/plain, text/html" \
	                       -F die-on=warning \
	                       -F file=@painttiming.bs) && \
	[[ "$$HTTP_STATUS" -eq "200" ]]) || ( \
		echo ""; cat painttiming.html; echo ""; \
		rm -f painttiming.html; \
		exit 22 \
	);

remote: painttiming.html

ci: painttiming.bs
	mkdir -p out
	make remote
	mv painttiming.html out/index.html
	cp filmstrip.svg filmstrip.png out/

clean:
	rm painttiming.html

