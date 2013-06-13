```
Based on the Zookeeper module by wikimedia. Thanks!

This fork brings CDH4 support along with Redhat support
```

# Puppet Zookeeper Module

Installs and configures a Zookeeper client and/or Zookeeper server.

This module has been implemented and tested on CentOS6, and uses
the Zookeeper package in upstream RedHat repositories.
As the forks origin was made for Debian/Ubuntu its likely to work there, 
yet untested. If someone tries it and reports, I'll fix hickups.

# Usage

```puppet
class { 'zookeeper':
    hosts    => { 'zoo1.domain.org' => 1, 'zoo2.domain.org' => 2, 'zoo3.domain.org' => 3 },
    data_dir => '/var/lib/zookeeper',
}
```

The above setup should be used to configure a 3 node zookeeper cluster.
You can include the above class on any of your nodes that will need to talk
to the zookeeper cluster.

On the 3 zookeeper server nodes, you should also include:

```puppet
class { 'zookeeper::server': }
```

This will ensure that the zookeeper server is running.
Remember that this requires that you also include the
zookeeper class as defined above as well as the server class.

On each of the defined zookeeper hosts, a myid file must be created
that identifies the host in the zookeeper quorum.  This myid number
will be extracted from the hosts Hash keyed by the node's $fqdn.
E.g.  zoo1.domain.org's myid will be '1', zoo2.domain.org's myid will be 2, etc.
