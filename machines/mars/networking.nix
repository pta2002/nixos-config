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
  };
}
