# Authoritative build rules for tick.

# If you don't have GNU Make on your system, use this file as a
# cribsheet for how to build various aspects of tick.

STYLESDIR = ../asciidoctor-stylesheet-factory/stylesheets
STYLESHEET = juxt.css

.PHONY: 		watch default deploy test dev-docs-cljs

default:		docs/index.html

# Build the docs
docs/index.html:	docs/*.adoc docs/docinfo*.html ${STYLESDIR}/${STYLESHEET}
			asciidoctor -d book \
			-a "webfonts!" \
			-a stylesdir=../${STYLESDIR} \
			-a stylesheet=${STYLESHEET} \
			docs/index.adoc

test-clj:
			clojure -Atest -e deprecated
test-cljs:
			rm -rf cljs-test-runner-out && mkdir -p cljs-test-runner-out/gen && clojure -Sverbose -Atest-cljs

test:
			make test-clj && make test-cljs

# For developing the cljs used by the documentation, add --repl and change docs.cljs.edn optimizations to :none to develop interactively
dev-docs-cljs:
			npm i; clojure -Adocs-index

pom:
			rm pom.xml; clojure -Spom; echo "Now use git diff to add back in the non-generated bits of pom"
deploy:			
			mvn deploy
figwheel:
			clj -R:dev:dev-nrepl:dev-rebel -C:dev:dev-nrepl:dev-rebel:test -m figwheel.main --build tick --repl

# hooray for stackoverflow
.PHONY: list
list:
		@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | xargs
