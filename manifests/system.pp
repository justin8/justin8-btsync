class btsync::system(
  $listening_port = 0,
  $storage_path = '/var/lib/btsync/system',
  $user = 'btsync',
  $group = 'btsync',
  $umask = '0002',
  $use_upnp = true,
  $download_limit = 0,
  $upload_limit = 0,
  $proxy = false,
  $proxy_type = 'socks4',
  $proxy_addr = '127.0.0.1',
  $proxy_port = '8080',
  $proxy_username = '',
  $proxy_password = '',
  $webui_listen = '127.0.0.1:8888',
  $login = undef,
  $password = undef,
  $directory_root = '/',) {
  contain btsync

  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin'
  }

  validate_absolute_path($storage_path)
  validate_bool($use_upnp)
  validate_re($listening_port, '\d+')
  validate_re($download_limit, '\d+')
  validate_re($upload_limit, '\d+')
  validate_re($umask, '\d{4}')
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
    content => template('btsync/system-service.d.conf.erb'),
    notify  => [ Service['btsync'], Exec['systemd-daemon-reload'] ],
  }

  file { '/etc/btsync.conf':
    owner   => $user,
    group   => $group,
    mode    => '0644',
    notify  => Service['btsync'],
    content => template('btsync/system-btsync.conf.erb'),
  }

  file { $storage_path:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    mode    => '2775',
    notify  => [ Service['btsync'], Exec['fix-btsync-storage-permissions'] ],
  }

  exec { 'fix-btsync-storage-permissions':
    path        => $::path,
    command     => "chown -R ${user}:${group} '${storage_path}'",
    refreshonly => true,
  }

  file { "${storage_path}/sync.log":
    ensure  => file,
    owner   => $user,
    group   => $group,
    mode    => '0664',
  }

  exec { 'sync permissions':
    command => "setfacl -d -m g::rwx '${storage_path}'",
    unless  => "getfacl '${storage_path}' | grep default",
    require => File[$storage_path],
  }

}
