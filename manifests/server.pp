# == Class zookeeper::server
# Configures a zookeeper server.
# This requires that zookeeper is installed
# And that the current nodes fqdn is an entry in the
# $::zookeeper::hosts array.
#
# == Parameters
# $log_file            - zookeeper.log file.    Default: /var/log/zookeeper/zookeeper.log
#
class zookeeper::server(
    $log_file         = $::zookeeper::defaults::log_file,
    $default_template = $::zookeeper::defaults::default_template,
    $log4j_template   = $::zookeeper::defaults::log4j_template
)
{
    # need zookeeper common package and config.
    Class['zookeeper'] -> Class['zookeeper::server']

    # Install zookeeper server package
    package { 'zookeeper-server':
        ensure    => $::zookeeper::version,
    }

    file { '/etc/zookeeper/conf/log4j.properties':
        content => template($log4j_template),
        require => Package['zookeeper'],
    }

    file { $::zookeeper::data_dir:
        ensure => 'directory',
        owner  => 'zookeeper',
        group  => 'zookeeper',
        mode   => '0755',
    }

    # Get this host's $myid from the $fqdn in the $zookeeper_hosts hash.
    $myid = $::zookeeper::hosts[$::fqdn]

    # init the zookeeper data dir
    exec { 'zookeeper-server-initialize':
        command => "/usr/bin/zookeeper-server-initialize --myid=${myid}",
        unless  => "/usr/bin/test -f $::zookeeper::data_dir/myid",
        user    => "zookeeper",
        require => Package['zookeeper'],
    }

    # replace the generated myid file with a link to /etc/zookeepeer/conf/
    file { '/etc/zookeeper/conf/myid':
        content => $myid,
    }
    file { "${::zookeeper::data_dir}/myid":
        ensure  => 'link',
        target  => '/etc/zookeeper/conf/myid',
        require => Exec['zookeeper-server-initialize'],
    }

    service { 'zookeeper-server':
        ensure     => running,
        require    => [
            Package['zookeeper-server'],
            Package['zookeeper'],
            Exec['zookeeper-server-initialize'],
        ],
        hasrestart => true,
        hasstatus  => true,
        subscribe  => [
            File['/etc/zookeeper/conf/zoo.cfg'],
            File['/etc/zookeeper/conf/myid'],
            File['/etc/zookeeper/conf/log4j.properties'],
        ],
    }

}
