
##
## FujiNet tools Master Make file.
## Hack-o-matic, for sure, it will get better.
##

.PHONY: all mostlyclean clean install zip

.SUFFIXES:

all mostlyclean clean install zip:
	@$(MAKE) -C fconfig   --no-print-directory $@	
	@$(MAKE) -C feject    --no-print-directory $@
	@$(MAKE) -C fhost     --no-print-directory $@
	@$(MAKE) -C fld       --no-print-directory $@
	@$(MAKE) -C flh       --no-print-directory $@
	@$(MAKE) -C fls       --no-print-directory $@
	@$(MAKE) -C fmount    --no-print-directory $@
	@$(MAKE) -C fmall     --no-print-directory $@
	@$(MAKE) -C fnet      --no-print-directory $@
	@$(MAKE) -C fnew      --no-print-directory $@
	@$(MAKE) -C freset    --no-print-directory $@
	@$(MAKE) -C fscan     --no-print-directory $@
	@$(MAKE) -C rlisten   --no-print-directory $@
	@$(MAKE) -C ncd       --no-print-directory $@
	@$(MAKE) -C npwd      --no-print-directory $@
	@$(MAKE) -C ndir      --no-print-directory $@
	@$(MAKE) -C ncopy     --no-print-directory $@
	@$(MAKE) -C ndel      --no-print-directory $@
	@$(MAKE) -C nmkdir    --no-print-directory $@
	@$(MAKE) -C nrmdir    --no-print-directory $@
#	@$(MAKE) -C rulisten  --no-print-directory $@
dist: all
	mkdir -p dist
	cp fconfig/fconfig.com dist/
	cp feject/feject.com dist/
	cp fhost/fhost.com dist/
	cp fld/fld.com dist/
	cp flh/flh.com dist/
	cp fls/fls.com dist/
	cp fmount/fmount.com dist/
	cp fmall/fmall.com dist/
	cp fnet/fnet.com dist/
	cp fnew/fnew.com dist/
	cp freset/freset.com dist/
	cp fscan/fscan.com dist/
	cp rlisten/rlisten.com dist/
	cp ncd/ncd.com dist/
	cp npwd/npwd.com dist/
	cp ndir/ndir.com dist/
	cp ncopy/ncopy.com dist/
	cp ndel/ndel.com dist/
	cp nmkdir/nmkdir.com dist/
	cp nrmdir/nrmdir.com dist/
#	cp rulisten/rulisten.com dist/
	cp -ax doc/* dist/ 
	dir2atr 720 fnc-tools.atr dist/
