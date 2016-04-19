# adapted from the htmltools package; we only need this one function
urlEncodePath = function (x) 
{
  enc = utils::URLencode(x, reserved=TRUE)
  gsub("%2[Ff]", "/", enc)
}

#' Create or Update a Digest Authentication File
#'
#' Use this function to create or edit 'htdigest'-style HTTP digest authentication
#' files for the \code{\link{mongoose}} back end. Depending on the authentication
#' settings (global or per-directory), you may use just one global file or a file
#' in each subdirectory of the mongoose data directory.
#' @param file An 'htdigest'-style file to create or update.
#' @param realm The authentication realm.
#' @param user User name.
#' @param password User password.
#' @return Invoked for the side effect of creating or updating \code{file}.
#' @note See \url{https://httpd.apache.org/docs/current/programs/htdigest.html}.
#' @export
htdigest = function(file, realm, user, password)
{
  entry = sprintf("%s:%s:%s", user, realm,
            digest::digest(charToRaw(sprintf("%s:%s:%s", user, realm, password)), serialize=FALSE, algo="md5"))
  f = tryCatch(readLines(file), error=function(e) c(), warning=function(e) c())
  key = sprintf("%s:%s:", user, realm)
  idx = grep(key, f)
  if(length(idx) > 0)
  {
    f[idx[1]] = entry
  }
  else f = c(f, entry)
  writeLines(f, con=file)
}
