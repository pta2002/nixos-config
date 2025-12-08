{
  # This is needed since we still have some references to the deluge user.
  users.groups.deluge = {};

  users.users.deluge = {
    uid = 83;
    group = "deluge";
    home = "/var/lib/deluge";
    isSystemUser = true;
    extraGroups = [ "data" ];
  };
}
