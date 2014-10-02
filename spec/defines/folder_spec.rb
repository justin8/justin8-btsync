require 'spec_helper'

['Archlinux'].each do |osfamily|
  describe 'btsync::folder', type: :define do
    let(:facts) { { osfamily: osfamily } }
    let(:title) { '/test/folder' }
    config_file = '/var/lib/btsync/custom/test-folder/btsync.conf'

    context 'test default values' do
      let(:params) { { 'secret' => '1' } }
      it { should contain_file(config_file).with_content(/"secret" : "1"/) }
      it { should contain_file(config_file).with_content(%r{"dir" : "/test/folder"}) }
      it { should contain_file(config_file).with_content(/"listening_port" : 0/) }
      it { should contain_file(config_file).with_content(%r{"storage_path" : "/var/lib/btsync/custom/test-folder"}) }
      it { should contain_file(config_file).with_content(/"use_upnp" : true/) }
      it { should contain_file(config_file).with_content(/"download_limit" : 0/) }
      it { should contain_file(config_file).with_content(/"upload_limit" : 0/) }
      it { should contain_file(config_file).with_content(/"use_relay_server" : false/) }
      it { should contain_file(config_file).with_content(/"use_tracker" : false/) }
      it { should contain_file(config_file).with_content(/"use_dht" : true/) }
      it { should contain_file(config_file).with_content(/"search_lan" : true/) }
      it { should contain_file(config_file).with_content(/"use_sync_trash" : true/) }
      it { should contain_file(config_file).with_content(/"overwrite_changes" : false/) }
      it { should contain_file(config_file).with_content(%r{"pid_file" : "/var/run/btsync/test-folder-btsync.pid"}) }
    end

    context 'test changed values' do
      let(:params) { { 'secret' => '123456abcdef',
                       'owner' => 'foo',
                       'group' => 'bar',
                       'listening_port' => '9000',
                       'use_upnp' => false,
                       'download_limit' => '100',
                       'upload_limit' => '200',
                       'use_relay_server' => true,
                       'use_tracker' => true,
                       'use_dht' => false,
                       'search_lan' => false,
                       'sync_trash' => false,
                       'overwrite_changes' => true } }
      it { should contain_file(config_file).with_content(/"secret" : "123456abcdef"/) }
      it { should contain_file(config_file).with_content(%r{"dir" : "/test/folder"}) }
      it { should contain_file(config_file).with_content(/"listening_port" : 9000/) }
      it { should contain_file(config_file).with_content(%r{"storage_path" : "/var/lib/btsync/custom/test-folder"}) }
      it { should contain_file(config_file).with_content(/"use_upnp" : false/) }
      it { should contain_file(config_file).with_content(/"download_limit" : 100/) }
      it { should contain_file(config_file).with_content(/"upload_limit" : 200/) }
      it { should contain_file(config_file).with_content(/"use_relay_server" : true/) }
      it { should contain_file(config_file).with_content(/"use_tracker" : true/) }
      it { should contain_file(config_file).with_content(/"use_dht" : false/) }
      it { should contain_file(config_file).with_content(/"search_lan" : false/) }
      it { should contain_file(config_file).with_content(/"use_sync_trash" : false/) }
      it { should contain_file(config_file).with_content(/"overwrite_changes" : true/) }
      it { should contain_file(config_file).with_content(%r{"pid_file" : "/var/run/btsync/test-folder-btsync.pid"}) }
    end
  end
end
