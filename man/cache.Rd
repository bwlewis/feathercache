% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/io.R
\name{cache}
\alias{cache}
\title{Upload an R Value to an Object Store}
\usage{
cache(con, value, key, xdr = FALSE)
}
\arguments{
\item{con}{An object store connection from \code{\link{register_service}}.}

\item{value}{Any serializeable R value.}

\item{key}{A key name, optionally including a \code{/} separated directory path}

\item{xdr}{set \code{xdr=TRUE} to use big-endian binary format, defaults to native binary}
}
\value{
A character string corresponding to the url of the uploaded object.
}
\description{
Upload the R \code{value} to the object store connection \code{con} with the key name and
optional path specified by \code{key}.
}
\note{
Key names are url-encoded and may be changed (\code{cache} returns the uri of the
stored value). The forward slash character \code{/} is NOT url-encoded and reserved for directory
path information. Do not use any slash (forward or backward) in your key names, they will
be interpreted as directory separators.
}
\examples{
# Start an example local mongoose backend server
mongoose_start()
con <- register_service()
# Cache the 'iris' dataset in a directory named 'mydata':
cache(con, iris, "mydata/iris")
# Retrieve it from the cache into a new variable called 'x'
x <- uncache(con, "mydata/iris")
# Delete the entire 'mydata' directory
delete(con, "mydata")
mongoose_stop()
}
\seealso{
\code{\link{register_service}} \code{\link{uncache}} \code{\link{delete}}
}

