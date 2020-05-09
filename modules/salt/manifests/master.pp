class salt::master(
    Optional[String] $salt_interface             = undef,
    Optional[String] $salt_worker_threads = undef,
    String $salt_runner_dirs    = '/srv/runners',
    String $salt_file_roots     = '/srv/salt',
    String $salt_pillar_roots   = '/srv/pillar',
    Hash $salt_ext_pillar       = {},
    String $salt_reactor_root   = '/srv/reactors',
    Hash $salt_reactor          = {},
    Hash $salt_peer             = {},
    Hash $salt_peer_run         = {},
    Hash $salt_nodegroups       = {},
    String $salt_state_roots    = '/srv/salt',
    String $salt_module_roots   = '/srv/salt/_modules',
    String $salt_returner_roots = '/srv/salt/_returners',
) {
    include salt::apt

    include ssl::wildcard

    # May be installed in the future again,
    # but with proper measures in place.
    package { 'salt-master':
        ensure  => 'absent',
    }

    # Do NOT install and run this service
    # on any Miraheze server. Salt is NOT safe
    # for usage here, EVEN with the patch in place.
    service { 'salt-master':
        ensure  => stopped,
        enable  => true,
        require => Package['salt-master'],
    }

    file { '/etc/salt/master':
        content => template('salt/master.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        notify  => Service['salt-master'],
        require => Package['salt-master'],
    }

    file { $salt_runner_dirs:
        ensure => directory,
        mode   => '0755',
        owner  => 'root',
        group  => 'root',
    }

    file { "${salt_runner_dirs}/keys.py":
        ensure => present,
        source => 'puppet:///modules/salt/keys.py',
        mode   => '0755',
        owner  => 'root',
        group  => 'root',
    }

    file { $salt_reactor_root:
        ensure => directory,
        mode   => '0755',
        owner  => 'root',
        group  => 'root',
    }


    # this also is the same as $salt_state_roots
    file { $salt_file_roots:
        ensure => directory,
        mode   => '0755',
        owner  => 'root',
        group  => 'root',
    }

    file { $salt_pillar_roots:
        ensure => directory,
        mode   => '0755',
        owner  => 'root',
        group  => 'root',
    }

    file { $salt_module_roots:
        ensure => directory,
        mode   => '0755',
        owner  => 'root',
        group  => 'root',
    }

    file { $salt_returner_roots:
        ensure => directory,
        mode   => '0755',
        owner  => 'root',
        group  => 'root',
    }

    sysctl::parameters { 'salt-master':
        values => {
            'net.core.somaxconn'          => 4096,
            'net.core.netdev_max_backlog' => 4096,
            'net.ipv4.tcp_mem'            => '16777216 16777216 16777216',
        }
    }

    # Reducing permissions on the master cache, by default is 0755
    file { '/var/cache/salt/master':
        ensure => directory,
        mode   => '0750',
        owner  => 'root',
        group  => 'root',
    }

    $hostips = query_nodes("domain='$domain' and Class[Role::Salt::Minions]", 'ipaddress')
    
    $hostips.each |$key| {
        ufw::allow { 'salt master port 4505 ipv4':
            proto   => 'tcp',
            port    => 4505,
            from    => $key,
        }

        ufw::allow { 'salt master port 4506 ipv4':
            proto   => 'tcp',
            port    => 4506,
            from    => $key,
        }
    }

    $hostips6 = query_nodes("domain='$domain' and Class[Role::Salt::Minions]", 'ipaddress6')
    $hostips6.each |$key| {
        ufw::allow { 'salt master port 4505 ipv6':
            proto   => 'tcp',
            port    => 4505,
            from    => $key,
        }

        ufw::allow { 'salt master port 4506 ipv6':
            proto   => 'tcp',
            port    => 4506,
            from    => $key,
        }
    }
}
