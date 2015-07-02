class btsync::system( $listening_port = 0,
                      $storage_path = '/var/lib/btsync/system',
                      $user = 'btsync',
                      $group = 'btsync',
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
    require => Exec['systemd-daemon-reload'],
  }

  file { '/etc/systemd/system/btsync.service.d':
    ensure => directory,
  }

  file { '/etc/systemd/system/btsync.service.d/user.conf':
    ensure  => present,
    content => template('btsync/user.conf.erb'),
    notify  => [ Service['btsync'], Exec['systemd-daemon-reload'] ],
  }

  file { '/etc/btsync.conf':
    owner   => $user,
    group   => $group,
    mode    => '0644',
    require => Package['btsync'],
    notify  => Service['btsync'],
    content => template('btsync/btsync.conf.erb'),
  }

  file { $storage_path:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    mode    => '2775',
    require => Package['btsync'],
    notify  => Service['btsync'],
  }

  file { "${storage_path}/sync.log":
    ensure  => file,
    owner   => $user,
    group   => $group,
    mode    => '0664',
    require => Package['btsync'],
  }

  file { "/var/run/btsync/btsync.pid":
    owner  => $user,
    group  => $group,
    before => Service['btsync'],
  }

  cron { 'btsync perms':
    command  => "/usr/bin/chmod -R g+w '${storage_path}'",
    minute   => '*',
    hour     => '*',
    month    => '*',
    monthday => '*',
    weekday  => '*',
    require  => File[$storage_path],
  }

  exec { 'sync permissions':
    command => "setfacl -d -m g::rwx '${storage_path}'",
    unless  => "getfacl '${storage_path}' | grep default",
    require => File[$storage_path],
  }

}
