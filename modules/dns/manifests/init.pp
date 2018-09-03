# dns
class dns {
    include ::apt

    if os_version('debian jessie') {
        apt::source { 'debian_stretch':
            comment  => 'Debian Stretch APT',
            location => 'http://ftp.debian.org/debian',
            release  => 'stretch',
            repos    => 'main contrib non-free',
        }

        # Workaround for https://github.com/miraheze/puppet/issues/70
        apt::pin { 'debian_stable':
            priority => 995,
            release  => 'stable',
        }

        apt::pin { 'debian_stretch':
            priority   => 740,
            originator => 'Debian',
            release    => 'stretch',
            packages   => 'gdnsd',
        }
    } else {
        apt::pin { 'debian_stretch_backports':
            priority   => 740,
            originator => 'Debian',
            release    => 'stretch-backports',
            packages   => 'gdnsd',
        }
    }

    package { 'gdnsd':
        ensure  => installed,
        require => File['/etc/apt/preferences'],
    }

    service { 'gdnsd':
        ensure     => running,
        hasrestart => true,
        hasstatus  => true,
        require    => [ Package['gdnsd'], Exec['gdnsd-syntax'] ],
    }

    exec { 'gdnsd-syntax':
        command     => '/usr/sbin/gdnsd checkconf',
        notify      => Service['gdnsd'],
        refreshonly => true,
    }

    git::clone { 'dns':
        ensure    => latest,
        directory => '/etc/gdnsd',
        origin    => 'https://github.com/miraheze/dns.git',
        owner     => 'root',
        group     => 'root',
        before    => Package['gdnsd'],
        notify    => Exec['gdnsd-syntax'],
    }

    file { '/usr/lib/nagios/plugins/check_gdnsd_datacenters':
        ensure => present,
        source => 'puppet:///modules/dns/check_gdnsd_datacenters.py',
        mode   => '0755',
    }

    icinga2::custom::services { 'Auth DNS':
        check_command => 'check_dns_auth',
        vars          => {
            host    => 'miraheze.org',
        },
    }

    icinga2::custom::services { 'GDNSD Datacenters':
        check_command => 'nrpe',
        vars          => {
            nrpe_command => 'check_gdnsd_datacenters',
        },
    }
}
