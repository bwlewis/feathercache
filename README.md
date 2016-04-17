# feathercache

A stupid simple networked object store for R (and Python). We're calling this
*feather*cache because someday we plan on caching feather
(https://github.com/wesm/feather) objects in it for use with R, Python, and
other languages. For now it's just a really simple, generic, networked binary
object store.

Feathercache supports GET/PUT/DELETE-style operations using modular back end
storage services.  Out of the box support is provided by the included
`mongoose` web service, but we also plan to support `minio` (https://minio.io)
and Amazon S3 object storage services.

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

* Cross-platform, works on Windows, Mac OS X and Linux systems.
* Simple, standard GET/PUT/DELETE-style operations
* Modular storage back ends: `mongoose` (default), `minio`, S3, Azure blob (someday?), ...


## Mongoose back end

The package includes a back end based on Cesanta's excellent `mongoose` web
server (https://github.com/cesanta/mongoose) with TLS encryption, digest
authentication, optional auto-forwarded requests between servers in cluster,
and JSON directory listings.

Mongoose runs out of the box on all operating system platforms with zero to
minimal configuration, or optionally can be installed as a system service.


