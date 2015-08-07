# class: hhvm
class hhvm {
    include ::apt
    apt::source { 'HHVM_apt':
        comment  => 'HHVM apt repo',
        location => 'http://dl.hhvm.com/debian',
        release  => 'jessie',
        repos    => 'main',
        key      => {
            'id'     => '0x5a16e7281be7a449',
            'server' => 'hkp://keyserver.ubuntu.com:80',
        },
    }

    $packages = [
        'php-pear',
        'php-mail',
        'php5',
        'php5-curl',
        'php5-gd',
        'php5-imagick',
        'php5-intl',
        'php5-json',
        'php5-mcrypt',
        'php5-mysqlnd',
        'php5-redis',
    ]

    package { $packages:
        ensure => present,
    }

    package { 'hhvm-nightly':
        ensure  => present,
        require => Apt::Source['HHVM_apt'],
    }

    service { 'hhvm':
        ensure => 'running',
    }

    file { '/etc/hhvm/php.ini':
        ensure  => present,
        source  => 'puppet:///modules/hhvm/php.ini',
        require => Package['hhvm-nightly'],
        notify  => Service['hhvm'],
    }

    include private::hhvm

    file { '/etc/hhvm/server.ini':
        ensure  => present,
        content => template('hhvm/server.ini.erb'),
        require => Package['hhvm-nightly'],
        notify  => Service['hhvm'],
    }
}
