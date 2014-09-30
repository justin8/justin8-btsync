Overview
--------

The btsync puppet module allows you to manage multiple BitTorrent Sync instances with Puppet.


Usage
-----

Just include the `btsync::system` class to enable a system-wide configuration with the webui enabled.
This by default this will have the webui accessible via localhost only.

```puppet
include btsync::system
```

If you wish to enable remote access to the webui:

```puppet
class { 'btsync::system':
    webui => 'remote',
}
```

Syncing individual folders
--------------------------

Declare a folder to be synced. This will create an individual service per folder.

```puppet
btsync::folder { '/path/to/folder':
    secret => 'abcdefg',
    path   => '/alternate/path/instead/of/title',
    owner  => 'root',
    group  => 'root',
    sync_trash => true,
}
```

Reference
---------

Classes:

* [btsync](#class-btsync)

Resources:

* [btsync::system](#class-btsyncsystem)
* [btsync::folder](#class-btsyncfolder)

###Class: btsync
Install btsync.
You should not declare this class explicitely, it should be done by btsync class.

###Class: btsync::system
This resource is used to declare a system-wide btsync daemon to be run.

####`webui`
Whether the webui should be available remotely or not. Valid settings: 'local' or 'remote'. Defaults to 'local'

###Class: btsync::folder
This resource is used to declare an individual folder that is to be synced.
Each instance will result in its own service being generated.

####`ensure`
Either present or absent. If set to absent it will cause an error after the removal due to bug PUP-2188.

####`secret`
A read/write or read-only secret generated with
    btsync --generate-secret
or
    btsync --get-ro-secret $secret

####`path`
The path to sync; Defaults to title.

####`owner`
The owner for the folder and subdirectories

####`group`
The group for the folder and subdirectories

####`sync_trash`
The sync_trash parameter from btsync.conf

TODO
----

* Support the other options for btsync.conf
* Create unit tests
* Add explicit support for extra OSes
