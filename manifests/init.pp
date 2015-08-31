class btsync( $webui = 'local' ) {
  include systemd

  if $::operatingsystem == 'Archlinux' {
    ensure_packages(['btsync'])
  } else {
    ensure_packages(['curl'])

    exec { 'download-btsync':
      command => '/usr/bin/curl -o /tmp/btsync.tar.gz https://download-cdn.getsync.com/stable/linux-x64/BitTorrent-Sync_x64.tar.gz',
    }~>
    exec { 'extract-btsync':
      command => 'cd /usr/bin; tar xf /tmp/btsync.tar.gz btsync',
    }

    file { '/etc/systemd/system/btsync.service':
      source => 'puppet:///modules/btsync/btsync.service',
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
  }

}
