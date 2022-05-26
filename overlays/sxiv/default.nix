self: super: {
  sxiv = super.sxiv.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./on_top.patch ];
  });
}
