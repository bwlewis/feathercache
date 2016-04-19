# *nix Makefile

MODULE_CFLAGS=-DMG_DISABLE_CGI -DVERSION=\"$(GIT_VERSION)\"

CFLAGS = -g -W -Wall -I../.. -Wno-unused-function $(CFLAGS_EXTRA) $(MODULE_CFLAGS) -lssl -lcrypto -lpthread -ldl

all:
	$(CC) mongoose.c -o mongoose $(CFLAGS)

clean:
	rm -rf *.gc* *.dSYM *.exe *.obj *.o a.out mongoose *.deb *.rpm
