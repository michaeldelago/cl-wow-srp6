LISP:=qlot exec ros run

.PHONY += test
test:
	$(LISP) -s cl-wow-srp6 \
					--eval '(asdf:test-system :cl-wow-srp6)' \
					--quit \
					-- --non-interactive

# Install formatter with command:
# $(LISP) ros install hyotang666/trivial-formatter
.PHONY += fmt
fmt:
	$(LISP) --non-interactive \
					--eval '(asdf:load-system :trivial-formatter)' \
					--eval '(trivial-formatter:fmt :cl-wow-srp6 :supersede)' \
					--quit
