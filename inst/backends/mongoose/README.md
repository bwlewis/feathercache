# The feathercache mongoose backend

Stupid simple cross-platform web object store service based on mongoose.

## Requirements

On Debian/Ubuntu systems you'll need at least:
```
sudo apt-get install libssl-dev
```


## Compile
```
make
```

Set up a self-signed TLS certificate with:
```
openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 1000 -nodes && cat cert.pem key.pem >> ssl.pem && rm cert.pem key.pem
```
Then put the `key.pem` file in a path available to mongoose specified with the `-P <cert file>` option.

## Start an ad hoc mongoose server from R

See documentation for the `mongoose_start()` function for possible options.
```r
library(feathercache)
mongoose_start()
```

## Install mongoose as a system service on Linux

The package includes scripts that can install mongoose as a service. First,
install the R package then run (assuming R is in your PATH):

```
sudo $(R --slave -e "cat(system.file('backends/mongoose/service_linux/mongoose-installer.sh', package='feathercache'))")
```
The script installs the files:

* `/usr/local/bin/mongoose`
* `/etc/init.d/mongoose`
* `/etc/mongoose.conf`

You'll almost certainly want to examine and possible edit (as the root user) the
`/etc/mongoose.conf` file; this file controls all the mongoose options like the
object storage path and importantly which user the mongoose server runs as
(`nobody` by default).

If you do edit the `/etc/mongoose.conf` file, then restart the service for your
changes to take effect:
```
/etc/init.d/mongoose stop
/etc/init.d/mongoose start
```

Un-install the service with
```
sudo $(R --slave -e "cat(system.file('backends/mongoose/service_linux/mongoose-uninstaller.sh', package='feathercache'))")
```

## Install as a service on Windows

(Write me)

## Install as a service on Mac OS X

(Write me)

## Authentication

Mongoose provides optional basic HTTP digest authentication for global and/or
per-directory access control.

### Global authentication example

```
# adding user 'blewis' with authentication domain 'realm'
 htdigest -c .htpasswd realm blewis

# Specify the same authentication domain 'realm' when starting mongoose
./mongoose -a realm -P .htpasswd
```

### Per-directory user access control

Use the `-A <access file>` option and place an htdigest file in each directory
to control access on a per-directory level. Directories without an access file
are globally accessible, unless a global authentication file is set.

Only one of the `-A` or `-P` options may be used.


## Auto redirect

Start a cluster of `mongoose` servers on different machines with the `-f`
option pointing in a ring between the servers. For instance,
```
# server_a: ./mongoose -f http://server_b:8000
# server_b: ./mongoose -f http://server_c:8000
# server_c: ./mongoose -f http://server_a:8000
```

GET requests (`uncache` in the R package) that result in "404 not found"
errors are returned to the client as redirects to the next server.

This simple approach lets you store key/values across several servers using any
desired sharding strategy and locate a given key without advance knowledge of
its location. Not terribly efficient, but reasonably effective.
