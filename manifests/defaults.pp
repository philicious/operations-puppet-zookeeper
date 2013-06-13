# == Class zookeeper::defaults
# Default zookeeper configs.
class zookeeper::defaults {
    $hosts            = { "${::fqdn}" => 1 }

    $data_dir         = '/var/lib/zookeeper'
    $data_log_dir     = undef
    $log_file         = '/var/log/zookeeper/zookeeper.log'

    # Default puppet paths to template config files.
    # This allows us to use custom template config files
    # if we want to override more settings than this
    # module yet supports.
    $conf_template    = 'zookeeper/zoo.cfg.erb'
    $log4j_template   = 'zookeeper/log4j.properties.erb'

    # Zookeeper package version.
    $version          = 'installed'
}
