lib:
let
  fs = lib.fileset;
  sshKeyFiles = fs.toList (fs.fileFilter (file: file.hasExt "pub") ./keys);
in
map builtins.readFile sshKeyFiles
