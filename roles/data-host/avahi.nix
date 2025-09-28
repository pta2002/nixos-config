{ ... }:
{
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    # Maybe?
    nssmdns6 = false;

    openFirewall = true;
    publish = {
      enable = true;
      userServices = true;
      addresses = true;
    };

    # TODO: For whatever reason, this does not work?
    # It seems that the _adisk._tcp service gives me some type of permission error, but I don't know why...
    extraServiceFiles = {
      # Taken from https://www.reddit.com/r/homelab/comments/83vkaz/howto_make_time_machine_backups_on_a_samba/
      timeMachine = # xml
        ''
          <?xml version="1.0" standalone='no'?>
          <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
          <service-group>
            <name replace-wildcards="yes">%h</name>
            <service>
              <type>_smb._tcp</type>
              <port>445</port>
            </service>
            <service>
              <type>_device-info._tcp</type>
              <port>0</port>
              <txt-record>model=RackMac</txt-record>
            </service>
            <service>
              <type>_adisk._tcp</type>
              <txt-record>sys=waMa=0,adVF=0x100</txt-record>
              <txt-record>dk0=adVN=TimeMachine Home,adVF=0x82</txt-record>
            </service>
          </service-group>
        '';
    };
  };
}
