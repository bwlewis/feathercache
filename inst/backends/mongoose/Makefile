# Basic compilation:
# make
# With TLS/SSL enabled:
# SSL_LIB=openssl make

MODULE_CFLAGS=-DMG_DISABLE_CGI -DMG_DISABLE_DAV_AUTH -DMG_ENABLE_FAKE_DAVLOCK -DCS_ENABLE_DEBUG

SOURCES = mongoose.c
CFLAGS = -g -W -Wall -I../.. -Wno-unused-function $(CFLAGS_EXTRA) $(MODULE_CFLAGS)

all: $(PROG)

ifeq ($(OS), Windows_NT)
CFLAGS := $(CFLAGS) -lws2_32
CC = gcc
else
ifeq ($(SSL_LIB),openssl)
CFLAGS := $(CFLAGS) -DMG_ENABLE_SSL -lssl -lcrypto
else ifeq ($(SSL_LIB), krypton)
CFLAGS := $(CFLAGS) -DMG_ENABLE_SSL -DMG_DISABLE_PFS ../../../krypton/krypton.c
endif
CFLAGS := $(CFLAGS) -lpthread
endif

all: $(SOURCES)
	$(CC) $(SOURCES) -o mongoose $(CFLAGS)

mongoose.exe: $(SOURCES)
	cl $(SOURCES) /I../.. /MD /Fe$@

clean:
	rm -rf *.gc* *.dSYM *.exe *.obj *.o a.out mongoose
