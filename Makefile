SHELL=/bin/bash
LEMMY=lemmy-help

doc:
	@mkdir -p doc
	$(LEMMY) -fat lua/pandoc/{init.lua,config.lua,render.lua,utils.lua} > doc/pandoc.txt

.PHONY: doc
