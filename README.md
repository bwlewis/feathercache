# THIS IS A DEFUNCT PROJECT, REPLACED WITH A NEW PROJECT

I'm keeping this repository here for posterity. The new version of this project
will be called share and may be found here: https://github.com/bwlewis/share

Please avoid using this and instead use the new share package, this project will no longer be
maintained or developed by me...

# feathercache

A stupid simple networked object store for R For now it's just a really simple,
self-contained, generic, networked binary object store.

Feathercache supports GET/PUT/DELETE-style operations using modular back end
storage services. Our R package calls those operations `cache()`, `uncache()`,
and `delete()`.

Out of the box support is provided by the included mongoose web service, but
we also plan to support minio (https://minio.io) and Amazon S3 object storage
services.

## Status
<a href="https://travis-ci.org/bwlewis/feathercache">
<img src="https://travis-ci.org/bwlewis/feathercache.svg?branch=master" alt="Travis CI status"></img>
</a>
[![codecov.io](https://codecov.io/github/bwlewis/feathercache/coverage.svg?branch=master)](https://codecov.io/github/bwlewis/feathercache?branch=master)

## Installation (R example)

You'll need the `devtools` package, for instance from `install.packages("devtools")`.

```{r}
devtools::install_github("bwlewis/lz4")   # required dependency for now
devtools::install_github("bwlewis/feathercache")
```

## Quickstart (R example)

```{r}
library(feathercache)
mongoose_start()                      # starts a local mongoose server on port 8000
con <- register_service()             # register the local mongoose backend
cache(con, iris, key="mystuff/iris")  # put a copy of iris in the 'mystuff' directory
cache(con, cars, key="mystuff/cars")  # put a copy of cars in the 'mystuff' directory

print(uncache(con, "mystuff"))        # list the contents of 'mystuff'
#    key               mod size
# 1 cars 24-Apr-2016 13:13  455
# 2 iris 24-Apr-2016 13:13 2032

head(uncache(con, "mystuff/iris"))    # retrieve iris from the cache
#   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
# 1          5.1         3.5          1.4         0.2  setosa
# 2          4.9         3.0          1.4         0.2  setosa
# 3          4.7         3.2          1.3         0.2  setosa
# 4          4.6         3.1          1.5         0.2  setosa
# 5          5.0         3.6          1.4         0.2  setosa
# 6          5.4         3.9          1.7         0.4  setosa

delete(con, "mystuff")                # delete the whole 'mystuff' directory
mongoose_stop()
```

## Use case

We often see a need for, as simply as possible, sharing native R values like
data frames between R processes running across many computers. Many good
options are of course available, including:

* Networked file systems like NFS (perhaps the simplest option)
* Networked databases including key/value stores

But we wanted an approach that works out of the box without dependencies, and
could optionally work with some more sophisticated external systems without
modification. We also wanted speed, multiple options for scalability, speed,
the simplicity of a file system, _and most important, we want to work with data
in native R or Python form to minimize or eliminate data marshaling cost._ And
speed.

We see our approach working well with lightweight distributed computing systems
that are decoupled from I/O like R's foreach and doRedis packages
(https://github.com/bwlewis/doRedis), and Python's superb celery system
(http://www.celeryproject.org/).

## Anti use case

Feathercache is *not* a database. Right now, no claims to data consistency are
made and a lot of things are left up to the clients (R, whatever). Think of it
as a very crude networked object storage service like S3.  Forthcoming backends
may support varying consistency levels, but even so feathercache is not a
database. Use a database if you think you need a database.  Or, coordinate
activity in the cache using an external system like
https://github.com/coreos/etcd !

## Features

* Planning to be cross-platform for Windows, Mac OS X and Linux systems, right now testing/developing on Linux.
* Simple standard GET/PUT/DELETE-style operations
* Modular storage back ends: mongoose (default), minio, Amazon S3, Azure blob (someday?), ...

## Storage back ends

The package is equipped with a self-contained simple but relatively fast HTTP/S
backend service using Mongoose (see below for many more details).

But feathercache is designed to work with arbitrary object storage systems.
Future support for the S3 protocol is planned.

## Back end API

Mongoose requires storage back ends to support the following REST-like
operations:

* get
* put
* delete
* head

These operations directly correspond to HTTP 1.1 verbs, and map to the
corresponding high-level R package functions `uncache()`, `cache()`,
`delete()`, and `info()`.

## Mongoose back end

The package includes a back end based on Cesanta's excellent mongoose web
server (https://github.com/cesanta/mongoose) with TLS encryption, digest
authentication, optional auto-forwarded requests between servers in a cluster,
and JSON directory listings.

Mongoose runs out of the box on all operating system platforms with zero to
minimal configuration, or optionally can be installed as a system service.

Data stored by mongoose are relative to a user-configurable data directory and
are stored in plain old files that can be read directly (without the networked
object storage service).

Mongoose data files and directories are directly compatible with minio data
and can be used interchangeably with that service when it's ready.


## A bit more on the use case

You might be thinking, why not just use Redis (http://redis.io) or whatever?
Indeed Redis is pretty awesomely fast, well-supported across multiple operating
systems, and has tons of features beyond simple GET/PUT. But Redis has some
issues too, for example, values are limited to a relatively small size.  And if
you want to just copy the "database" for offline analysis or backup, the values
and keys are not simple files and need to be accessed through Redis itself.
Those issues are typical of many databases. Mongodb (https://www.mongodb.org/)
and RethinkDB (http://rethinkdb.com/), for instance, are superb document
databases.  But values are limited to a very small size, although GridFS
(https://docs.mongodb.org/manual/core/gridfs/) is an option but that brings
additional configuration complexity, and they're geared to working with
structured values in JSON form, not arbitrary serialized R objects.

Apache Geode (http://geode.incubator.apache.org/) is super fast, has very
large value size limits (terabytes), and provides very strong consistency
in distributed settings to boot. Not bad! But it's a huge software project
with a gigantic footprint that needs to be installed and maintained on a
cluster. Which is fine if that's what you're already using, but might be
a pain if you just want a fast way to share data across a bunch of R and
Python processes.

Finally, very traditional networked databases like PostgreSQL and MySQL can
store binary blobs and be used just like this, while also providing added
transactional and consistency protections on the data. I seriously considered
using PostgreSQL for this project in fact, and indeed it still could be
outfitted as another modular back end. But I found the object store path
compelling because of the potential scalability/performance potential of
minio with their "XL" erasure-coded back end, and of course the proven
scalability of S3 (at least if you're running in Amazon's ecosystem).

Feathercache, by contrast, is trivially simple. Just point the built-in
Mongoose service to a directory and serve data. Or use an S3 back end.

# More documentation:

## Mongoose back end
https://github.com/bwlewis/feathercache/blob/master/inst/backends/mongoose/README.md

The package includes a basic HTTP/S object store service based on the
Cesanta mongoose web server (https://github.com/cesanta/mongoose). The
service is compiled with the R package and ready to run out of the box
(at least, for now, on Linux -- other operatings systems soon).

See https://github.com/bwlewis/feathercache/blob/master/inst/backends/mongoose/README.md
for more information and details on installing the mongoose back end as a system
service.

## minio back end
Not ready yet!

## Amazon S3 back end
Not ready yet!
