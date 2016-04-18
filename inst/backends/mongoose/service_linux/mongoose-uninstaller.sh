#!/bin/bash

echo "Un-installing the mongoose service..."
/etc/init.d/mongoose stop
if test -n "`which update-rc.d`"; then
  update-rc.d -f mongoose remove
else
  chkconfig --del mongoose
fi
rm -f /etc/init.d/mongoose
rm -f /etc/mongoose.conf
rm -f /usr/local/bin/mongoose
