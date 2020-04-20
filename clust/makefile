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

kdnn.so: src/kdnn.c src/k.h
	$(CC) $(CFLAGS) $(OSXOPTS) $(LNK) -Isrc -o kdnn.so src/kdnn.c $(LDRPATH)

src/k.h:
	curl -s -L https://github.com/KxSystems/kdb/raw/master/c/c/k.h -o src/k.h 

install:
	install kdnn.so $(Q)

clean:
	rm kdnn.so
