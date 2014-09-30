define btsync::folder(
  $ensure = present,
  $secret,
  $path = $title,
  $owner = 'root',
  $group = 'root',
  $listening_port = 0,
  $use_upnp = true,
  $download_limit = 0,
  $upload_limit = 0,
  $use_relay_server = false,
  $use_tracker = false,
  $use_dht = true,
  $search_lan = true,
  $sync_trash = true,
  $overwrite_changes = false)  {
  include btsync

  $int_path = regsubst($path, '/', '')
  $clean_path = regsubst($int_path, '/', '-', 'G')
  $service_name = "${clean_path}-btsync.service"
  $config_folder = "/var/lib/btsync/custom/${clean_path}"
  $config = "${config_folder}/btsync.conf"

  if $ensure == 'absent' {
    # This will print an un-necessary error after it has been removed.
    # A bug for this is already open with puppet: PUP-2188
    service { $service_name:
      ensure => stopped,
      enable => false,
    }

    file {
      [ $path,
        $config_folder,
        $config,
        "/etc/systemd/system/${service_name}" ]:
        ensure  => absent,
        require => Service[$service_name];
    }
  } else {

    exec { "${clean_path}-daemon-reload":
      command     => 'systemctl daemon-reload',
      refreshonly => true,
      notify      => Service[$service_name];
    }

    # TODO: Handle the key being changed, would require purging and recreating config directories
    file {
      "/etc/systemd/system/${service_name}":
        content => template('btsync/folder.service.erb'),
        notify  => Exec["${clean_path}-daemon-reload"];

      [ $path, $config_folder ]:
        ensure => directory,
        owner  => $owner,
        group  => $group;

      $config:
        content => template('btsync/folder.conf.erb'),
        notify  => Service[$service_name];
    }

    service { $service_name:
      ensure => running,
      enable => true,
    }

  }

}
