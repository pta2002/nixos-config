{ ... }: {
  programs.tiny = {
    enable = true;
    settings = {
      servers = [
        {
          addr = "irc.libera.chat";
          port = 6697;
          tls = true;
          realname = "Pedro Alves";
          nicks = [ "pta2002" ];
        }
      ];
      defaults = {
        nicks = [ "pta2002" ];
        realname = "Pedro Alves";
        join = [ "irc.libera.chat" ];
        tls = true;
      };
    };
  };
}
