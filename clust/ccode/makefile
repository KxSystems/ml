CFLAGS=-DKXVER=3 -O2
ifeq ($(shell uname),Linux)
LDFLAGS=-fPIC -shared
LDRPATH=-Wl,-rpath,'$$ORIGIN'
QLIBDIR=l64
else ifeq ($(shell uname),Darwin)
LDFLAGS=-dynamiclib -undefined dynamic_lookup
LDRPATH=-Wl,-rpath,@loader_path
QLIBDIR=m64
.PHONY: print_vars

endif
cure.so: cure.c cure.h kdtree.so kdtree.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o cure.so cure.c kdtree.so $(LDRPATH)
kdtree.so: kdtree.c kdtree.h 
	$(CC) $(CFLAGS) $(LDFLAGS) -o kdtree.so kdtree.c $(LDRPATH)

%.so: %.c %.h
ifeq ($(shell uname),Linux)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $*.c
else ifeq ($(shell uname),Darwin)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $*.c -install_name @rpath/$@	
	print_vars:
		@echo $(otool) -L kdtree.so

endif

%.c: %.qtemplate.c
	q qc.q -q $< > $@
%.h: %.qtemplate.h
	q qc.q -q $< > $@

clean:
	for f in $$(ls *.[ch]|grep -v "qtemplate"|grep -v "^k.h"); do echo rm $$f; rm $$f ; done
cleanall: clean
	if [ -f cure.so ]; then rm cure.so ; fi	
	if [ -f kdtree.so ]; then rm kdtree.so ; fi	
	
	

