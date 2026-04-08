lib:
let
  fs = lib.fileset;
  sshKeyFiles = fs.fileFilter (file: file.hasExt "pub") ./keys |> fs.toList;
in
map builtins.readFile sshKeyFiles
