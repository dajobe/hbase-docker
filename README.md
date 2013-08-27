HBase in Docker
===============

This configuration builds a docker container to run HBase (with
embedded Zookeeper) running on the files inside the container.


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

    $ id=$(docker run -d dajobe/hbase)

Find out the web UI ports:

	$ host='localhost'
	$ master_ui_port=$(docker port $id 60010)
	$ region_ui_port=$(docker port $id 60030)
	$ thrift_ui_port=$(docker port $id 9095)

Construct the URLs to check it out:

    $ echo "http://$host:$master_ui_port/master-status"
	$ echo "http://$host:$region_ui_port/rs-status"
	$ echo "http://$host:$thrift_ui_port/thrift.jsp"

Find out the API ports:

	$ master_api_port=$(docker port $id 60000)
	$ region_api_port=$(docker port $id 60020)
	$ thrift_api_port=$(docker port $id 9090)

See HBase Logs
--------------

If you want to see the latest logs live use:

    $ docker attach $id

Then ^C to detach.

To see all the logs since the HBase server started, use:

    $ docker logs $id

and ^C to detach again.


Test HBase is working via python over Thrift
--------------------------------------------

Here I am using a remote docker machine called `precise` which could
be `localhost` if I was running this locally.  The port is the
`$thrift_api_port` because happybase[1] uses Thrift to talk to HBase.

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

  * http://localhost:60030/master-status for the Master Server
  * http://localhost:60010/rs-status for Region Server
  * http://localhost:9095/thrift.jsp for the thrift UI
  * http://localhost:60030/zk.jsp for the embedded Zookeeper

to see what's going on in the container and since both your local
machine and the container are using localhost (aka 127.0.0.1), even
the links work!





Notes
-----

Although there is an embedded zookeeper running on the server on port
2181 it is not being forwarded.

[1] http://happybase.readthedocs.org/en/latest/
