# The feathercache mongoose backend

Stupid simple cross-platform web object store service based on mongoose.

## Compile
```
make
```

### Compile a TLS server
```
SSL_LIB=openssl make
```
Set the key up with:
```
openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 1000 -nodes && cat cert.pem key.pem >> ssl.pem && rm cert.pem key.pem
```

## Start a server from R

```r
library(feathercache)
mongoose_start()
```

## Install as a service on Linux

(Write me)

## Install as a service on Windows
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


## Installation as a system service (Linux)

The package includes scripts and makefiles that can build an OS-specific
installable mongoose package for Debian/Ubuntu and RHEL/CentOS operating
systems. A service version of mongoose can then be installed from the
package (and easily removed later if you like, thus the package format).



### Ubuntu

```
sudo apt-get install ruby-dev
sudo gem install fpm
```
