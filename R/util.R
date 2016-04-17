# adapted from the htmltools package; we only need this one function
urlEncodePath = function (x) 
{
  enc = utils::URLencode(x, reserved=TRUE)
  gsub("%2[Ff]", "/", x)
}
