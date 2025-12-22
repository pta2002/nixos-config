{
  pkgs,
  config,
  ...
}:
let
  cfg = config.programs.ccache;
in
{
  programs.ccache = {
    enable = pkgs.stdenv.hostPlatform.isAarch64;
  };

  nix.settings.extra-sandbox-paths = [ cfg.cacheDir ];

  nixpkgs.overlays = [
    (self: super: {
      ccacheWrapper = super.ccacheWrapper.override {
        extraConfig = ''
          export CCACHE_COMPRESS=1
          export CCACHE_SLOPPINESS=random_seed
          export CCACHE_DIR="${cfg.cacheDir}"
          export CCACHE_UMASK=007
          if [ ! -d "$CCACHE_DIR" ]; then
            echo "====="
            echo "Directory '$CCACHE_DIR' does not exist"
            echo "Please create it with:"
            echo "  sudo mkdir -m0770 '$CCACHE_DIR'"
            echo "  sudo chown ${cfg.owner}:${cfg.group} '$CCACHE_DIR'"
            echo "====="
            exit 1
          fi
          if [ ! -w "$CCACHE_DIR" ]; then
            echo "====="
            echo "Directory '$CCACHE_DIR' is not accessible for user $(whoami)"
            echo "Please verify its access permissions"
            echo "====="
            exit 1
          fi
        '';
      };
    })
  ];
}
