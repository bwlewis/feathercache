check = function(a, b)
{
  print(match.call())
  stopifnot(all.equal(a, b, check.attributes=FALSE, check.names=FALSE))
}

library("feathercache")
mongoose_start()
con <- register_service()             # register the local mongoose
cache(con, iris, key="mystuff/iris")  # put a copy of iris in the 'mystuff' directory
cache(con, cars, key="mystuff/cars")  # put a copy of cars in the 'mystuff' directory

d <- uncache(con, "mystuff")          # list the contents of 'mystuff'
check(all(c("cars", "iris") %in% d$key), TRUE)
x <- uncache(con, "mystuff/iris")      # retrieve iris from the cache
check(iris, x)
mongoose_stop()
