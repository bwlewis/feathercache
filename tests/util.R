check = function(a, b)
{
  print(match.call())
  stopifnot(all.equal(a, b, check.attributes=FALSE, check.names=FALSE))
}

library("feathercache")
file = tempfile()
htdigest(file, "realm", "user", "password")
check("user:realm:ebbc0ff9a121dbb6789bbe5f82174fa0", system(paste("cat", file), intern=TRUE))
htdigest(file, "realm", "user", "password")
check("user:realm:ebbc0ff9a121dbb6789bbe5f82174fa0", system(paste("cat", file), intern=TRUE))
