class btsync::system( $listening_port = 0,
                      $storage_path = '/var/lib/btsync',
                      $use_upnp = true,
                      $download_limit = 0,
                      $upload_limit = 0,
                      $webui_listen = '127.0.0.1:8888',
                      $login = undef,
                      $password = undef,
                      $directory_root = '/',) {
  include btsync

  validate_re($listening_port, '\d+')
  validate_absolute_path($storage_path)
  validate_bool($use_upnp)
  validate_re($download_limit, '\d+')
  validate_re($upload_limit, '\d+')
  validate_absolute_path($directory_root)


  service { 'btsync':
    ensure  => running,
    enable  => true,
    require => Package['btsync'],
  }

  file { '/etc/btsync.conf':
    owner   => 'btsync',
    group   => 'btsync',
    mode    => '0600',
    require => Package['btsync'],
    notify  => Service['btsync'],
    content => template('btsync/btsync.conf.erb'),
  }

  file { '/var/lib/btsync/sync':
    ensure  => directory,
    owner   => 'btsync',
    group   => 'btsync',
    mode    => '2775',
    require => Package['btsync'],
  }

  cron { 'btsync perms':
    command  => '/usr/bin/chmod -R g+w /var/lib/btsync/sync',
    minute   => '*',
    hour     => '*',
    month    => '*',
    monthday => '*',
    weekday  => '*',
  }

  exec { 'sync permissions':
    command => 'setfacl -d -m g::rwx /var/lib/btsync/sync',
    unless  => 'getfacl /var/lib/btsync/sync | grep default',
    require => File['/var/lib/btsync/sync'],
  }

}
