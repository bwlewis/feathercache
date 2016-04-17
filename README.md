# feathercache

A stupid simple networked object store for R (and Python), delivered as an R
package for now. We're calling this *feather*cache because someday we plan on
caching feather (https://github.com/wesm/feather) objects in it for use with R,
Python, and other languages. For now it's just a really simple, generic,
networked binary object store.

Feathercache supports GET/PUT/DELETE-style operations using modular back end
storage services.  Out of the box support is provided by the included
`mongoose` web service, but we also plan to support `minio` (https://minio.io)
and Amazon S3 object storage services.


## Installation (R)

You'll need the `devtools` package, for instance from `install.packages("devtools")`.

```{r}
devtools::install_github("bwlewis/lz4")           # required dependency for now
devtools::install_github("bwlewis/feathercache")
```

## Use case

We often see a need for as simply as possible sharing native R objects like
data frames between R processes running across many computers. Many good
options are of course available, including:

* Networked file systems like NFS, perhaps the simplest option
* Networked databases, including key/value stores and others

But we wanted an approach that works out of the box without dependencies, but
could optionally work with some more sophisticated external systems without
modification. We also wanted a system that is fast, reasonably scalable, simple
like a file system, and tailored for native R (or Python) objects because R and
Python of course.

## Features

* Eventually plan to be cross-platform for Windows, Mac OS X and Linux systems, right now testing/developing on Linux.
* Simple, standard GET/PUT/DELETE-style operations
* Modular storage back ends: `mongoose` (default), `minio`, S3, Azure blob (someday?), ...


## Mongoose back end

The package includes a back end based on Cesanta's excellent `mongoose` web
server (https://github.com/cesanta/mongoose) with TLS encryption, digest
authentication, optional auto-forwarded requests between servers in cluster,
and JSON directory listings.

Mongoose runs out of the box on all operating system platforms with zero to
minimal configuration, or optionally can be installed as a system service.


## Quickstart (R)

```{r}
library(feathercache)
mongoose_start()                      # starts a local mongoose server on port 8000
con <- register_service()             # register the local mongoose
cache(con, iris, key="mystuff/iris")  # put a copy of iris in the 'mystuff' directory
cache(con, cars, key="mystuff/cars")  # put a copy of cars in the 'mystuff' directory

print(uncache(con, "mystuff"))        # list the contents of 'mystuff'
head(uncache(con, "mystuff/iris"))    # retrieve iris from the cache
mongoose_stop()
```
