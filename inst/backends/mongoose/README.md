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

Set up a self-signed TLS certificate with, for instance:
```
openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 -subj "/C=US/ST=MA/L=Cleveland/O=BWLewis/CN=$(hostname)" -keyout cert.pem 2>/dev/null >> cert.pem
```
Then put the `cert.pem` file in a path available to mongoose specified with the `-s <cert file>` option.

## Start an ad hoc mongoose server from R on port 8000

See documentation for the `mongoose_start()` function for possible options, including other ports.
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

We use the Apache `htdigest` program below. You can also use the `htdigest()`
function in the feathercache R package to generate and edit password files.

The mongoose server requires that you specify a global digest password file
with its full path, illustrated below as `/tmp/.htpasswd`.
```
# adding user 'blewis' with authentication domain 'realm'
 htdigest -c /tmp/.htpasswd realm blewis

# Specify the same authentication domain 'realm' when starting mongoose
# SPECIFY THE FULL PATH TO THE GLOBAL PASSWORD FILE
./mongoose -a realm -P /tmp/.htpasswd
```
The global
password file must be readable whatever user the mongoose server runs as,
of course, but it *does not* need to be located in the web server document
root directory path.

### Per-directory user access control

Control access per directory by placing a digest access control file named
`.htpasswd` in any directory in the mongoose web server document root path.
Directories without an access file are globally accessible, unless a global
authentication file is set. If both a global access file and a per-directory
access file are specified, the global file takes precedence.

## Auto redirect

Nifty!

Start a cluster of mongoose servers on different machines with the `-f`
option pointing in a ring between the servers. For instance,
```
# server_a: ./mongoose -f http://server_b:8000
# server_b: ./mongoose -f http://server_c:8000
# server_c: ./mongoose -f http://server_a:8000
```
GET and DELETE requests (`uncache()` and `delete()` in the R package) that
result in "404 not found" errors are returned to the client as redirects to the
next server. PUT requests are never redirected.

You can store key/values across several servers using any desired sharding
strategy and then clients may download or delete them without advance knowledge
of storage location. This approach introduces latency on the order of the
mongoose cluster size, but provides an *extremely* simple way to take advantage
of aggregated bandwidth from multiple servers. It wokrs best with smallish
numbers of mongoose servers.


### A redirect example on a single server

The example below starts two mongoose services running on different ports on
the same machine and serving data out of different paths to sort of emulate
running on different machines.

The example caches R objects on each service and then shows that they can
be retrieved from either service thanks to our simple redirection scheme.

The first part of the example below creates some temporary directories and
starts two local mongoose servers server data out of each directory,
respectively. The example then caches two R numeric vectors, one in each
server.
```{r}
library(feathercache)
path1 = sprintf("%s/1", tempdir())
path2 = sprintf("%s/2", tempdir())
dir.create(path1)
dir.create(path2)
mongoose_start(port=8001, forward_to="http://localhost:8002", path=path1)
mongoose_start(port=8002, forward_to="http://localhost:8001", path=path2)
con1 = register_service("http://localhost:8001")
con2 = register_service("http://localhost:8002")

cache(con1, 1:5, key="one")
# [1] "one"

cache(con2, 6:10, key="six")
# [1] "six"
```
We can list the contents of each server directory to verify that, indeed,
each service only shows one of the cached R objects.
```{r}
uncache(con1)
#               key               mod size
# 1             one 19-Apr-2016 16:59   69

uncache(con2)
#              key               mod size
# 1            six 19-Apr-2016 16:59   69
```
Finally, we retrieve the cached R vectors, but from the "wrong" servers.
With the mongoose `-f` option our requests are automatically redirected and work!
```{r}
uncache(con2, "one")
# [1] 1 2 3 4 5

uncache(con1, "six")
# [1]  6  7  8  9 10


mongoose_stop()  # terminate our example local mongoose servers
```


## Directory listings

We rigged the mongoose server in feathercache to report directory listings in
JSON form. This works nicely with the feathercache R package functions.
