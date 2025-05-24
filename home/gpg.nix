{
  programs.gpg = {
    enable = true;
  };
  services.gpg-agent = {
    enable = true;
    enableFishIntegration = true;
    defaultCacheTtl = 3600;
    extraConfig = ''
      pinentry-program "/mnt/c/Program Files (x86)/Gpg4win/bin/pinentry.exe"
    '';
  };
}
