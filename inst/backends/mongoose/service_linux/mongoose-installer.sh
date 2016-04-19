#!/bin/bash
#
# This is an experimental script that sets up mongoose to start
# automatically as a service. It installs the files:
#
# /etc/init.d/mongoose
# /usr/local/bin/mongoose
# /etc/mongoose.conf
# /usr/local/share/man/man1/mongoose.1
#
# and configures the mongoose init script to start in the usual runlevels.
# Edit the /etc/mongoose.conf file to set configuration parameters.
#
# Usage:
# sudo ./mongoose-installer.sh
#

echo "Installing /etc/init.d/mongoose script..."
cat > /etc/init.d/mongoose <<1ZZZ
#! /bin/bash
### BEGIN INIT INFO
# Provides:          mongoose
# Required-Start:    \$remote_fs \$syslog
# Required-Stop:     \$remote_fs \$syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: mongoose
# Description:       Simple HTTP/S object store service.
### END INIT INFO

# Author: B. W. Lewis <blewis@illposed.net>

# PATH should only include /usr/* if it runs after the mountnfs.sh script
PATH=/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/bin
DESC="Simple HTTP/S object store service."
NAME=doRedis
DAEMON=/usr/local/bin/mongoose
DAEMON_ARGS=/etc/mongoose.conf
PIDFILE=/var/run/mongoose.pid
SCRIPTNAME=/etc/init.d/mongoose

#
# Function that starts the daemon/service.
#
do_start()
{
  USER=\$(cat /etc/mongoose.conf | sed -n /^[[:blank:]]*user:/p | tail -n 1 | sed -e "s/#.*//" | sed -e "s/.*://" | sed -e "s/^ *//" | sed -e "s/[[:blank:]]*$//")
  DIR=\$(cat /etc/mongoose.conf | sed -n /^[[:blank:]]*path:/p | tail -n 1 | sed -e "s/#.*//" | sed -e "s/.*://" | sed -e "s/^ *//" | sed -e "s/[[:blank:]]*$//")
  PORT=\$(cat /etc/mongoose.conf | sed -n /^[[:blank:]]*port:/p | tail -n 1 | sed -e "s/#.*//" | sed -e "s/.*://" | sed -e "s/^ *//" | sed -e "s/[[:blank:]]*$//")
  SSL=\$(cat /etc/mongoose.conf | sed -n /^[[:blank:]]*ssl_cert:/p | tail -n 1 | sed -e "s/#.*//" | sed -e "s/.*://" | sed -e "s/^ *//" | sed -e "s/[[:blank:]]*$//")
  AUTH=\$(cat /etc/mongoose.conf | sed -n /^[[:blank:]]*auth_domain:/p | tail -n 1 | sed -e "s/#.*//" | sed -e "s/.*://" | sed -e "s/^ *//" | sed -e "s/[[:blank:]]*$//")
  GLOB=\$(cat /etc/mongoose.conf | sed -n /^[[:blank:]]*global_auth_file:/p | tail -n 1 | sed -e "s/#.*//" | sed -e "s/.*://" | sed -e "s/^ *//" | sed -e "s/[[:blank:]]*$//")
  LL=\$(cat /etc/mongoose.conf | sed -n /^[[:blank:]]*log_level:/p | tail -n 1 | sed -e "s/#.*//" | sed -e "s/.*://" | sed -e "s/^ *//" | sed -e "s/[[:blank:]]*$//")
  FORW=\$(cat /etc/mongoose.conf | sed -n /^[[:blank:]]*forward_to:/p | tail -n 1 | sed -e "s/#.*//" | sed -e "s/.*://" | sed -e "s/^ *//" | sed -e "s/[[:blank:]]*$//")

  # Set default values
  [ -z "\${DIR}" ]   && DIR=/tmp
  [ -z "\${PORT}" ]   && PORT=8000
  [ -n "\${DIR}" ] && DIR="-d \${DIR}"
  [ -n "\${PORT}" ] && PORT="-p \${PORT}"
  [ -n "\${FORW}" ] && FORW="-f \${FORW}"
  [ -n "\${LL}" ] && LL="-l \${LL}"
  [ -n "\${GLOB}" ] && GLOB="-P \${GLOB}"
  [ -n "\${AUTH}" ] && AUTH="-a \${AUTH}"
  [ -n "\${SSL}" ] && SSL="-s \${SSL}"

  [ -z "\${USER}" ]   && USER=nobody
  sudo -b -n -E -u \${USER} /usr/local/bin/mongoose \${DIR} \${PORT} \${FORW} \${LL} \${GLOB} \${AUTH} \${SSL} 0<&- 2> >(logger  -i -t mongoose) &
}

#
# Function that stops the daemon/service, and it's a pretty dumb one (IMPROVE ME)
#
do_stop()
{
  killall mongoose
}


case "\$1" in
  start)
	do_start && echo "Started mongoose service" || echo "Failed to start mongoose service"
	;;
  stop)
	do_stop && echo "Stoped mongoose service"
	;;
  status)
       [[ \$(ps -aux | grep mongoose | grep "\\-d " | wc -l | cut -d ' ' -f 1) -gt 0 ]] && exit 0 || exit 1
       ;;
  *)
	echo "Usage: mongoose {start|stop|status}" >&2
	exit 3
	;;
esac

1ZZZ

echo "Installing /usr/local/bin/mongoose program..."
MG=$(R --slave -e 'cat(system.file("backends/mongoose/mongoose", package="feathercache"))')
[ -n "${MG}" ] && cp "${MG}" /usr/local/bin/mongoose

echo "Installing /etc/mongoose.conf configuration file                (you probably want to edit this)..."
cat > /etc/mongoose.conf << 3ZZZ
# /etc/mongoose.conf
# The format per line is
#
# key: vaule
#
# and the colon after the key is required! The settings
# may apper in any order. Everything after a '#' character is
# ignored per line. Default values appear below.
#
user: nobody        # user that runs the service
path: /tmp          # Object storage root path
port: 8000          # Mongoose service port number
log_level: 0        # 0-2 (0 error; 1 error + info; 2 error + info + debug)
#forward_to: URI    # forward "not found" requests to another mongoose
#ssl_cert: file     # TLS/SSL cert file (leave undefined to disable TLS)
#auth_domain: realm            # Digest authentication domain
#global_auth_file: file        # Digest global auth file
3ZZZ

cat > /usr/local/share/man/man1/mongoose.1 << 4ZZZ
.TH mongoose 1 "April 14th, 2016" "B. W. Lewis"
.SH NAME
mongoose \- Basic HTTP/S Object Store Service
.SH SYNOPSIS
.B mongoose
[\-h] [\-d \fIroot_path\fR] [\-p \fIport\fR] [\-s \fIssl_cert_file\fR] [\-a \fIauth_domain\fR] [\-P \fIglobal_auth_file\fR] [\-A \fIper_directory_auth_file\fR] [\-l \fIlog_level\fR] [\-f \fIforward_to_host\fR]
.SH DESCRIPTION
A super-basic HTTP/S service that supports a GET/PUT/DELETE object store.

.SH OPTIONS
.TP
.B \-h
Display help
.TP
.B \-d \fIroot_path\fR
Full path to the object store data directory.
.TP
.B \-p \fIport\fR
Listen on the specified port, 8000.
.TP
.B \-s \fIssl_cert_file\fR
Full path to a TLS/SSL certificate file, leave undefined to disable TLS.
.TP
.B \-a \fIauth_doman\fR
Digest authentication domain; requires \-P or \-A option below to enable digest authentication.
.TP
.B \-P \fIglobal_auth_file\fR
Path to global digest authentication file.
.TP
.B \-A \fIper_directory_auth_file\fR
Name of per-directory digest authentication file; at most one of \-P and \-A may be specified.
.TP
.B \-l \fIlog_level\fR
System message log level 0 (none) to 4 (crazy verbose debugging).
.TP
.B \-f \fIforward_to_host\fR
Service URI for another mongoose object store service; '404 not found' results are redirected
there.

.SH AUTHOR
Written by Bryan Wayne Lewis, blewis@illposed.net
.SH COPYRIGHT
Copyright (C) 2016 B. W. Lewis
4ZZZ

chmod a+x /etc/init.d/mongoose
if test -n "`which update-rc.d`"; then
  update-rc.d mongoose defaults
else
  chkconfig --level 35 mongoose on
fi
/etc/init.d/mongoose start
