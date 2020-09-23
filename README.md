HBase in Docker
===============

This configuration builds a docker container to run HBase (with
embedded Zookeeper) running on the files inside the container.

NOTE
----

The approach here requires editing the local server's `/etc/hosts`
file to add an entry for the container hostname.  This is because
HBase uses hostnames to pass connection data back out of the
container (from it's internal Zookeeper).

Hopefully this can be improved with Docker's newer networking
but this hasn't been fixed yet.


Build Image
-----------

    $ docker build -t dajobe/hbase .


Pull image
----------

If you want to pull the image already built then use this

    $ docker pull dajobe/hbase

More details at https://hub.docker.com/r/dajobe/hbase/


Run HBase
---------

I recommend using the start-hbase.sh script which will start the
container and inspect it to determine all the local API ports and Web
UIs plus will offer to edit /etc/hosts to add an alias for the
container IP, if not already present.

	$ ./start-hbase.sh
	start-hbase.sh: Starting HBase container
	start-hbase.sh: Container has ID b2db2fb3c3a67e20e2addd5e4d2ffc9a51abaafc3f9b36f464af7739e82f6446
	start-hbase.sh: /etc/hosts already contains hbase-docker hostname and IP
	start-hbase.sh: Connect to HBase at localhost on these ports
	  REST API             127.0.0.1:32874
	  Rest Web UI          http://127.0.0.1:32873/
	  Thrift API           127.0.0.1:32872
	  Thrift Web UI        http://127.0.0.1:32871/
	  HBase ZK             127.0.0.1:32875
	  HBase Master Web UI  http://127.0.0.1:32870/

	start-hbase.sh: OR Connect to HBase on container hbase-docker
	  REST API             hbase-docker:8080
	  Rest Web UI          http://hbase-docker:8085/
	  Thrift API           hbase-docker:9090
	  Thrift Web UI        http://hbase-docker:9095/
	  HBase ZK             hbase-docker:2181
	  HBase Master Web UI  http://hbase-docker:16010/

	start-hbase.sh: For docker status:
	start-hbase.sh: $ id=b2db2fb3c3a67e20e2addd5e4d2ffc9a51abaafc3f9b36f464af7739e82f6446
	start-hbase.sh: $ docker inspect $id

The localhost ports on the Host machine listed above 32870-32874 will
vary for every container and are ephemeral ports.

Alternatively, to run HBase by hand:

    $ mkdir data
    $ id=$(docker run --name=hbase-docker -h hbase-docker -d -v $PWD/data:/data dajobe/hbase)

and you will have to `docker inspect $id` to find all the ports.

If you want to run multiple hbase dockers on the same host, you can
give them different hostnames with the '-h' / '--hostname' argument.
You may have to give them different ports though.  Not tested.

If you want to customize the hostname used, set the
`HBASE_DOCKER_HOSTNAME` envariable on the docker command line


Find Hbase status
-----------------

Master status if docker container DNS name is 'hbase-docker'

    http://hbase-docker:16010/master-status

The region servers status pages are linked from the above page.

Thrift UI

    http://hbase-docker:9095/thrift.jsp

REST server UI

    http://hbase-docker:8085/rest.jsp

(Embedded) Zookeeper status

    http://hbase-docker:16010/zk.jsp


See HBase Logs
--------------

If you want to see the latest logs live use:

    $ docker attach $id

Then ^C to detach.

To see all the logs since the HBase server started, use:

    $ docker logs $id

and ^C to detach again.

To see the individual log files without using `docker`, look into
the data volume dir eg $PWD/data/logs if invoked as above.


Test HBase is working via python over Thrift
--------------------------------------------

Here I am connecting to a the container's thrift API port (such as
created by the start-hbase.sh script).  The port 32872 is the Thrift
API port exported to the host because [Happybase][1] [2] uses Thrift
to talk to HBase.

	$ python3
	Python 3.8.5 (default, Jul 21 2020, 10:48:26)
	[Clang 11.0.3 (clang-1103.0.32.62)] on darwin
	Type "help", "copyright", "credits" or "license" for more information.
	>>> import happybase
	>>> connection = happybase.Connection('127.0.0.1', 32872)
	>>> connection.create_table('table-name', { 'family': dict() } )
	>>> connection.tables()
	[b'table-name']
	>>> table = connection.table('table-name')
	>>> table.put('row-key', {'family:qual1': 'value1', 'family:qual2': 'value2'})
	>>> for k, data in table.scan():
	...   print(k, data)
	...
	b'row-key' {b'family:qual1': b'value1', b'family:qual2': b'value2'}
	>>>

(Simple install for happybase: `sudo pip install happybase` although I
use `pip install --user happybase` to get it just for me)


Test HBase is working from Java
-------------------------------

    $ docker run --rm -it --link $id:hbase-docker dajobe/hbase hbase shell
	HBase Shell
	Use "help" to get list of supported commands.
	Use "exit" to quit this interactive shell.
	For Reference, please visit: http://hbase.apache.org/2.0/book.html#shell
	Version 2.1.2, r1dfc418f77801fbfb59a125756891b9100c1fc6d, Sun Dec 30 21:45:09 PST 2018
	Took 0.0472 seconds
	hbase(main):001:0> status
	1 active master, 0 backup masters, 1 servers, 0 dead, 2.0000 average load
	Took 0.7255 seconds
	hbase(main):002:0> list
	TABLE
	table-name
	1 row(s)
	Took 0.0509 seconds
	=> ["table-name"]
    hbase(main):003:0>

Showing the `table-name` table made in the happybase example above.

Alternatively if you have the Hbase distribution available on the
host you can use `bin/hbase shell` if the hbase configuration has
been set up to connect to host `hbase-docker` zookeeper port 2181 to
get the servers via configuration property `hbase.zookeeper.quorum`



Proxy HBase UIs locally
-----------------------

If you are running docker on a remote machine, it is handy to see
these server-private urls in a local browser so here is a
~/.ssh/config fragment to do that

    Host my-docker-server
    Hostname 1.2.3.4
        LocalForward 127.0.0.1:16010 127.0.0.1:16010
        LocalForward 127.0.0.1:9095 127.0.0.1:9095
        LocalForward 127.0.0.1:8085 127.0.0.1:8085

When you `ssh my-docker-server` ssh connects to the docker server and
forwards request on your local machine on ports 16010 / 16030 to the
remote ports that are attached to the hbase container.

The bottom line, you can use these URLs to see what's going on:

  * http://localhost:16010/master-status for the Master Server
  * http://localhost:9095/thrift.jsp for the thrift UI
  * http://localhost:8085/rest.jsp for the REST server UI
  * http://localhost:16010/zk.jsp for the embedded Zookeeper

to see what's going on in the container and since both your local
machine and the container are using localhost (aka 127.0.0.1), even
the links work!





Notes
-----

[1] http://happybase.readthedocs.org/en/latest/

[2] https://github.com/wbolster/happybase
