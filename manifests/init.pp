class btsync( $webui = 'local' ) {
  include systemd

  package { 'btsync':
    ensure => present,
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
