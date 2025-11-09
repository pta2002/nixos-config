{
  networking = {
    interfaces.end0.ipv4.addresses = [
      {
        address = "192.168.1.10";
        prefixLength = 24;
      }
    ];

    defaultGateway = {
      address = "192.168.1.1";
      interface = "end0";
    };

    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
    ];
  };
}
