{
  pkgs,
  cacheHome,
}:
pkgs.writeShellScriptBin "cover-fetch" ''
  export PATH=${pkgs.lib.makeBinPath [pkgs.curl pkgs.jq pkgs.coreutils]}:$PATH
  export XDG_CACHE_HOME=''${XDG_CACHE_HOME:-${cacheHome}}
  ${builtins.readFile ./cover-fetch.sh}
''
