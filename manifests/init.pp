class btsync( $webui = 'local' ) {
  include systemd

  if $::operatingsystem == 'Archlinux' {
    ensure_packages(['btsync'])
  } else {
    ensure_packages(['curl'])

    exec { 'download-btsync':
      command => '/usr/bin/curl -o /tmp/btsync.tar.gz https://download-cdn.getsync.com/stable/linux-x64/BitTorrent-Sync_x64.tar.gz',
      unless  => '/usr/bin/test -f /usr/bin/btsync',
    }~>
    exec { 'extract-btsync':
      command     => 'tar xf /tmp/btsync.tar.gz btsync; chmod 755 /usr/bin/btsync',
      cwd         => '/usr/bin',
      refreshonly => true,
    }

    file { '/etc/systemd/system/btsync.service':
      source => 'puppet:///modules/btsync/btsync.service',
      notify => Exec['systemd-daemon-reload'],
    }

    user { 'btsync':
      ensure => present,
      home   => '/var/lib/btsync',
    }~>
    file { '/var/lib/btsync':
      owner => 'btsync',
      group => 'btsync',
    }
  }

  file {
    '/var/lib/btsync/custom':
      ensure => directory,
      purge  => true,
      force  => true;

    '/etc/tmpfiles.d/btsync.conf':
      ensure => file,
      source => 'puppet:///modules/btsync/btsync.conf';

    '/var/run/btsync':
      ensure => directory,
      owner  => 'btsync',
      group  => 'btsync',
      mode   => '0777';
  }

}
