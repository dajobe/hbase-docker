HBase in Docker
===============

This configuration builds a docker container to run HBase (with
embedded Zookeeper) running on the files inside the container.

NOTE
----

The current approach requires editing the local server's `/etc/hosts`
file to add an entry for the container hostname.  This is because
HBase uses hostnames to pass connection data back out of the
container (from it's internal Zookeeper).

Hopefully this can be fixed when newer Docker allows more advanced
networking such as fixed IPs or dynamic registration of name/IP
mappings (avahi?).


Build Image
-----------

	$ docker build -t dajobe/hbase .


Pull image
----------

If you want to pull the image already built then use this

    $ docker pull dajobe/hbase
	
More details at https://index.docker.io/u/dajobe/hbase/


Run HBase
---------

To run it without much utility use (NOT recommended):

    $ id=$(docker run -d dajobe/hbase)

To run it and proxy the ports locally and update `/etc/hosts`:

    $ ./start-hbase.sh

This will require you to enter your sudo password to edit /etc/hosts
and add an entry for a host called 'hbase-docker'.


Find Hbase status
-----------------

Find out the web UI ports:

	$ host='localhost'
	$ master_ui_port=$(docker port $id 60010)
	$ region_ui_port=$(docker port $id 60030)
	$ thrift_ui_port=$(docker port $id 9095)

Construct the URLs to check it out:

    $ echo "http://$host:$master_ui_port/master-status"
	$ echo "http://$host:$region_ui_port/rs-status"
	$ echo "http://$host:$thrift_ui_port/thrift.jsp"

With the raw `docker run` the API ports can be found at:

	$ master_api_port=$(docker port $id 60000)
	$ region_api_port=$(docker port $id 60020)
	$ thrift_api_port=$(docker port $id 9090)
	$ zk_api_port=$(docker port $id 2181)

With `start-hbase.sh` they are always the same local ones: 60000,
60020 and 9090 which HBase expects.


See HBase Logs
--------------

If you want to see the latest logs live use:

    $ docker attach $id

Then ^C to detach.

To see all the logs since the HBase server started, use:

    $ docker logs $id

and ^C to detach again.

To see the hbase thrift and server logs; use `start-hbase.sh` and
they will be written to the local directory `logs/` using a volume
mapping.


Test HBase is working via python over Thrift
--------------------------------------------

Here I am using a remote docker machine called `precise` which could
be `localhost` if I was running this locally.  The port is the
`$thrift_api_port` because [Happybase][1] [2] uses Thrift to talk to HBase.

	$ python
	Python 2.7.2 (default, Oct 11 2012, 20:14:37)
	[GCC 4.2.1 Compatible Apple Clang 4.0 (tags/Apple/clang-418.0.60)] on darwin
	Type "help", "copyright", "credits" or "license" for more information.
	>>> import happybase
	>>> connection = happybase.Connection('precise', 49168)
	>>> connection.create_table('table-name', { 'family': dict() } )
	>>> connection.tables()
	['table-name']
	>>> table = connection.table('table-name')
	>>> table.put('row-key', {'family:qual1': 'value1', 'family:qual2': 'value2'})
	>>> for k, data in table.scan():
	...   print k, data
	...
	row-key {'family:qual1': 'value1', 'family:qual2': 'value2'}
	>>>

(Simple install for happybase: `sudo pip install happybase` although I
use `pip install --user happybase` to get it just for me)


Test HBase is working from Java
-------------------------------

This requires using the `start-hbase.sh` approach and running in the
HBase source tree (might require `JAVA_HOME` to be set).

	$ bin/hbase shell
	HBase Shell; enter 'help<RETURN>' for list of supported commands.
	Type "exit<RETURN>" to leave the HBase Shell
	Version 0.94.11, r1513697, Wed Aug 14 04:54:46 UTC 2013

	hbase(main):001:0> status
	1 servers, 0 dead, 3.0000 average load

	hbase(main):002:0> list
	TABLE
	table-name
	1 row(s) in 0.0460 seconds

Showing the `table-name` table made in the happybase example above.


Proxy HBase UIs locally
-----------------------

If you are running docker on a remote machine, it is handy to see
these server-private urls in a local browser so here is a
~/.ssh/config fragment to do that

    Host my-docker-server
	Hostname 1.2.3.4
    LocalForward 127.0.0.1:$master_ui_port 127.0.0.1:60010
    LocalForward 127.0.0.1:$region_ui_port 127.0.0.1:60030
    LocalForward 127.0.0.1:$thrift_ui_port 127.0.0.1:9095

When you `ssh my-docker-server` ssh connects to the docker server and
forwards request on your local machine on ports 60010 / 60030 to the
remote ports that are attached to the hbase container.

The downside above is you have to edit the SSH config file every time
you restart docker because the ports will have changed.

The bottom line, you can use these URLs to see what's going on:

  * http://localhost:60010/master-status for the Master Server
  * http://localhost:60030/rs-status for Region Server
  * http://localhost:9095/thrift.jsp for the thrift UI
  * http://localhost:60030/zk.jsp for the embedded Zookeeper

to see what's going on in the container and since both your local
machine and the container are using localhost (aka 127.0.0.1), even
the links work!





Notes
-----

[1] http://happybase.readthedocs.org/en/latest/

[2] https://github.com/wbolster/happybase
