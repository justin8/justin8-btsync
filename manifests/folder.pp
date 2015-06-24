define btsync::folder(
  $secret,
  $ensure = present,
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
  $overwrite_changes = false,
  $proxy = false,
  $proxy_type = 'socks4',
  $proxy_addr = '127.0.0.1',
  $proxy_port = '8080',
  $proxy_username = '',
  $proxy_password = '',
  $ignore_list = [])  {
  include btsync

  validate_absolute_path($path)
  validate_bool($use_upnp, $use_relay_server, $use_tracker, $use_dht, $search_lan, $sync_trash, $overwrite_changes)
  validate_re($listening_port, '\d+')
  validate_re($download_limit, '\d+')
  validate_re($upload_limit, '\d+')

  if ! is_numeric($listening_port) {
    fail("Btsync::Folder[${title}]: listening_port should be a number")
  }

  if ! is_numeric($download_limit) {
    fail("Btsync::Folder[${title}]: download_limit should be a number")
  }

  if ! is_numeric($upload_limit) {
    fail("Btsync::Folder[${title}]: upload_limit should be a number")
  }

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

    # TODO: Handle the key being changed, would require purging and recreating config directories
    file {
      "/etc/systemd/system/${service_name}":
        content => template('btsync/folder.service.erb'),
        notify  => Exec['systemd-daemon-reload'];

      [ $path, "${path}/.sync", $config_folder ]:
        ensure  => directory,
        recurse => true,
        owner   => $owner,
        group   => $group;

      $config:
        ensure => file,
        owner  => $owner,
        group  => $group,
        content => template('btsync/folder.conf.erb'),
        notify  => Service[$service_name];

      "${path}/.sync/IgnoreList":
        ensure => file,
        owner  => $owner,
        group  => $group,
        content => template('btsync/folder.IgnoreList.erb'),
        notify  => Service[$service_name];
    }

    service { $service_name:
      ensure => running,
      enable => true,
    }

  }

}
