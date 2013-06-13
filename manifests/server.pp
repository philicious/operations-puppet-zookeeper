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
    file { '/etc/zookeeper/conf/myid':
        content => $myid,
    }
    file { "${::zookeeper::data_dir}/myid":
        ensure  => 'link',
        target  => '/etc/zookeeper/conf/myid',
    }

    service { 'zookeeper-server':
        ensure     => running,
        require    => [
            Package['zookeeper-server'],
            Package['zookeeper'],
            File[ $::zookeeper::data_dir],
            File["${::zookeeper::data_dir}/myid"],
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
