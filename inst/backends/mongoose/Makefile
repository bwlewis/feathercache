# *nix Makefile

MODULE_CFLAGS=-DMG_DISABLE_CGI -DMG_DISABLE_DAV_AUTH -DMG_ENABLE_FAKE_DAVLOCK -DCS_ENABLE_DEBUG

CFLAGS = -g -W -Wall -I../.. -Wno-unused-function $(CFLAGS_EXTRA) $(MODULE_CFLAGS) -DMG_ENABLE_SSL -lssl -lcrypto -lpthread

all:
	$(CC) mongoose.c -o mongoose $(CFLAGS)

clean:
	rm -rf *.gc* *.dSYM *.exe *.obj *.o a.out mongoose
