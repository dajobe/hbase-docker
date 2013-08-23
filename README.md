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

Find out the ports for the Master

	$ master_port=$(docker port $id 60010)
	$ region_port=$(docker port $id 60030)

Construct the URLs to check it out:

    $ echo "http://127.0.0.1:$master_port/master-status"
	$ echo "http://127.0.0.1:$region_port/rs-status"

See HBase Logs
--------------

If you want to see the latest logs live use:

    $ docker attach $id

Then ^C to detach.

To see all the logs since the HBase server started, use:

    $ docker logs $id

and ^C to detach again.


Proxy HBase UI locally
----------------------

It is handy to see these server-private urls in a local browser so 
here is a ~/.ssh/config fragment to do that

    Host my-docker-server
	Hostname 1.2.3.4
    LocalForward 127.0.0.1:$master_port 127.0.0.1:60010
    LocalForward 127.0.0.1:$region_port 127.0.0.1:60030

When you `ssh my-docker-server` ssh connects to the docker server and
forwards request on your local machine on ports 60010 / 60030 to the
remote ports that are attached to the hbase container.

The bottom line, you can use these URLs to see what's going on:

  * http://localhost:60030/master-status for the Master Server
  * http://localhost:60010/rs-status for Region Server
  * http://localhost:60030/zk.jsp for the embedded Zookeeper

to see what's going on in the container and since both your local
machine and the container are using localhost (aka 127.0.0.1), even
the links work!


Notes
-----

Although there is an embedded zookeeper running on the server on port
2181 it is not being forwarded.
