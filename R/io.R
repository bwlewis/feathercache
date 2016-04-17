#' Register an Object Store Service
#' Register an object store service backend, including backend-specific options
#' like authentication, encryption, and compression.
#' @param uri The service root URI including protocol, address and port number. For example \code{http://localhost:8000}.
#' @param backend A service backend provider. The default is \code{mongoose}, but you may choose from other available
#' backends like \code{minio} and {s3}.
#' @param ... Backend-specific arguments, see backend documentation for details.
#' @return A uri corresponding to the cached value.
#' @seealso \code{\link{mongoose}} \code{link{cache}} \code{\link{uncache}} \code{\link{delete}}
#' @examples
#' # Start an example local mongoose backend server
#' mongoose_start()
#' con <- register_service()
#' # Cache the 'iris' dataset in a directory named 'mydata':
#' cache(con, iris, "mydata/iris")
#' # Retrieve it from the cache into a new variable called 'x'
#' x <- uncache(con, "mydata/iris")
#' # Delete the entire 'mydata' directory
#' delete(con, "mydata")
#' mongoose_stop()
#' @export
register_service = function(uri="http://localhost:8000", backend=mongoose, ...)
{
  backend(uri, ...)
}

#' Retrieve a Value from an Object Store
#' Retrieve a value corresponding to the specified \code{key} from the object store service
#' connection \code{con}. If \code{key} corresponds to a directory, then a data frame listing
#' the directory contents is returned.
#' @param con An object store connection from \code{\link{register_service}}.
#' @param key A key name, optionally including a \code{/} separated directory path
#' @return Either a data frame directory listing in \code{key} corresponds to a directory,
#' or an R value corresponding to \code{key}.
#' @seealso \code{\link{register_service}} \code{\link{cache}} \code{\link{delete}}
#' @export
uncache = function(con, key)
{
  con("get", key=key)
}

#' Upload an R Value to an Object Store
#' Upload the R \code{value} to the object store connection \code{con} with the key name and
#' optional path specified by \code{key}.
#' @param con An object store connection from \code{\link{register_service}}.
#' @param value Any serializeable R value.
#' @param key A key name, optionally including a \code{/} separated directory path
#' @return A character string corresponding to the url of the uploaded object.
#' @note Key names are url-encoded and may be changed (see the returned value for the url of the
#' stored value). The forward slash character \code{/} is NOT url-encoded and reserved for directory
#' path information.
#' @seealso \code{\link{register_service}} \code{\link{uncache}} \code{\link{delete}}
#' @export
cache = function(con, value, key)
{
  con("put", value=value, key=key)
}

#' Deleta a Value or Directory from an Object Store
#' Delete the value or directory corresponding to the specified \code{key} from the object store service
#' connection \code{con}.
#' @param con An object store connection from \code{\link{register_service}}.
#' @param key A key name, optionally including a \code{/} separated directory path
#' @return \code{NULL} is invisibly returned, or an error may be thrown.
#' @seealso \code{\link{register_service}} \code{\link{cache}} \code{\link{uncache}}
#' @export
delete = function(con, key)
{
  con("delete", key=key)
}