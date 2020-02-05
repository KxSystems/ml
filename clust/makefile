OSFLAG :=
MS :=

ifeq ($(shell uname),Linux)
 LNK     = -lrt
 OSFLAG  = l
 OSXOPTS = -fPIC -shared
 LDRPATH = -Wl,-rpath,'$$ORIGIN'
else ifeq ($(shell uname),Darwin)
 OSFLAG  = m
 LNK:=
 OSXOPTS = -dynamiclib -undefined dynamic_lookup
 LDRPATH = -Wl,-rpath,"@loader_path" 
endif

CFLAGS= -DKXVER=3 -O2
MS    = $(shell getconf LONG_BIT)

QARCH = $(OSFLAG)$(MS)
Q     = $(QHOME)/$(QARCH) 

cure.so: src/cure.c src/cure.h kdtree.so src/kdtree.h
	$(CC) $(CFLAGS) $(OSXOPTS) $(LNK) -o cure.so src/cure.c kdtree.so $(LDRPATH)

kdtree.so: src/kdtree.c src/kdtree.h
	$(CC) $(CFLAGS) $(OSXOPTS) $(LNK) -o kdtree.so src/kdtree.c $(LDRPATH)

install:
	install cure.so kdtree.so $(Q)

clean:
	rm kdtree.so cure.so
