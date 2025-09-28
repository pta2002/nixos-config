{
  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    /mnt 100.0.0.0/8(fsid=0,rw,no_subtree_check,sec=sys)
    /mnt/data 100.0.0.0/8(rw,nohide,insecure,no_subtree_check,sec=sys)
  '';
}
