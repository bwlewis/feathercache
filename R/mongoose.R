#' Mongoose Object Store Backend
#'
#' Specify connection details for a \code{mongoose} web service object store backend,
#' the default simple back end included in the \code{feathercache} package.
#' @param uri The serivce uri, for instance \code{http://localhost:8000}.
#' @param ... Optional service parameters including:
#' \itemize{
#'   \item{user}{Optional HTTP digest authentication user name}
#'   \item{password}{Optional HTTP digest authentication user password}
#'   \item{ssl_verifyhost}{Optional SSL/TLS host verification, defaults to 0 (no verification)}
#'   \item{ssl_verifypeer}{Optional SSL/TLS peer verification, defaults to 0 (no verification)}
#'   \item{redirect_limit}{Should be set to the mongoose cluster size, defaults to 3}
#'   \item{compression}{Either 'lz4', 'xz', 'gzip' or 'none'.}
#' }
#' @note The mongoose back end stores R values in compressed (unless compression='none'), serialized form.
#' Default compression is lz4; change using the \code{compression} option.
#' @export
mongoose = function(uri, ...)
{
  base = uri
  opts = list(...)

  if(is.null(opts$compression)) opts$compression = "lz4"
  if(is.null(opts$ssl_verifyhost)) opts$ssl_verifyhost = 0
  if(is.null(opts$ssl_verifypeer)) opts$ssl_verifypeer = 0
  if(is.null(opts$redirect_limit)) opts$redirect_limit = 3

  getfun = switch(opts$compression,
             lz4=function(x) unserialize(lz4::lzDecompress(x)),
             gzip=function(x) unserialize(memDecompress(x, type="gzip")),
             xz=function(x) unserialize(memDecompress(x, type="xz")),
             function(x) unserialize(x))
  putfun = switch(opts$compression,
             lz4=function(x) lz4::lzCompress(serialize(x, NULL)),
             gzip=function(x) memCompress(serialize(x, NULL), type="gzip"),
             xz=function(x) memCompress(serialize(x, NULL), type="xz"),
             function(x) serialize(x, NULL))

  function(proto, ...)
  {
    h = curl::new_handle()
    on.exit(curl::handle_reset(h), add = TRUE)
    if("user" %in% names(opts) && "password" %in% names(opts))
    {
      # digest authentication
      curl::handle_setopt(h, httpauth=2, userpwd=paste(opts$user, opts$password, sep=":"))
    }
    curl::handle_setopt(h, .list=list(ssl_verifyhost=opts$ssl_verifyhost, ssl_verifypeer=opts$ssl_verifypeer,
                                      maxredirs=opts$redirect_limit, followlocation=52))
    args = list(...)

    url = paste(base, urlEncodePath(args$key), sep="/") ## XXX urlencode
    if(proto == "put")
    {
      curl::handle_setopt(h, .list = list(customrequest = "PUT"))
      data = putfun(args$value)
      curl::handle_setopt(h, .list=list(post=TRUE, postfieldsize=length(data), postfields=data))
      resp = curl::curl_fetch_memory(url, handle=h)
      if(resp$status_code > 299) stop("HTTP error ", resp$status_code)
      return(gsub(sprintf("%s/", base), "", resp$url))
    } else if(proto == "get")
    {
      resp = curl::curl_fetch_memory(url, handle=h)
      if(resp$status_code > 299) stop("HTTP error ", resp$status_code)
      hdr = rawToChar(resp$headers)
      type = tryCatch(
               gsub(" ", "", gsub("\\r\\n.*", "", strsplit(tolower(hdr),
                 split="content-type:")[[1]][2])), error=function(e) "application/binary")
      if(length(grep("application/json", type, ignore.case=TRUE) > 0)) # directory listing
      {
        ans = jsonlite::fromJSON(rawToChar(resp$content)) # XXX
        ans = ans[!(nchar(ans$key) == 0), ]
        ans$size = as.numeric(ans$size)
        return(ans)
      }
      return(getfun(resp$content)) ## XXX get rid of copy here? stream?
    }
    if(proto == "delete")
    {
      curl::handle_setopt(h, .list = list(customrequest = "DELETE"))
      resp = curl::curl_fetch_memory(url, handle=h)
      if(resp$status_code > 299) stop("HTTP error ", resp$status_code)
      return(resp$url)
    }
  }
}

#' Start a Mongoose Service
#' Manuall start a local mongoose service
#' @param port service port number
#' @param path full path to data directory
#' @param forward_to forward 'not found' requests to another server
#' @param ssl_cert TLS/SSL certificate
#' @param auth_domain HTTP digest authentication domain/realm
#' @param global_auth HTTP digest global authentication file
#' @note Leave parameters \code{NULL} to not use the corresponding features.
#' @return Nothing; the mongoose server is started up as a background process.
#' @export
mongoose_start = function(port=8000L,
                          path=getwd(),
                          forward_to=NULL,
                          ssl_cert=NULL,
                          auth_domain=NULL,
                          global_auth=NULL,
                          directory_auth=NULL)
{
  m = system.file("backends/mongoose/mongoose", package="feathercache")
  if(nchar(m) == 0) stop("mongoose not found!")
  cmd = sprintf("%s -l 0 -d %s", m, path)
  if(!is.null(forward_to)) cmd = sprintf("%s -f %s", cmd, forward_to)
  if(!is.null(ssl_cert)) cmd = sprintf("%s -s %s", cmd, ssl_cert)
  if(!is.null(auth_domain)) cmd = sprintf("%s -a %s", cmd, auth_domain)
  if(!is.null(global_auth)) cmd = sprintf("%s -P %s", cmd, global_auth)
  system(cmd, wait=FALSE)
}

#' Stop a Running Mongoose Service
#' FIX ME
#' @export
mongoose_stop = function()
{
  system("killall mongoose") # XXX FIX!
}
