{pkgs, ...}: {
  home.packages = with pkgs; [
    file
    ripgrep
    trash-cli
    xdg-utils
    chafa
    pistol
  ];

  programs.lf = {
    enable = true;
    keybindings = {
      D = "trash";
    };
    commands = {
      trash = "%trash-put $fx";
      fg = ''
        ''${{
            cmd="${pkgs.ripgrep}/bin/rg --column --line-number --no-heading --color=always --smart-case"
            ${pkgs.fzf}/bin/fzf --ansi --disabled --layout=reverse --header="Search in files" --delimiter=: \
                --bind="start:reload([ -n {q} ] && $cmd -- {q} || true)" \
                --bind="change:reload([ -n {q} ] && $cmd -- {q} || true)" \
                --bind='enter:become(lf -remote "send $id select \"$(printf "%s" {1} | sed '\'''s/\\/\\\\/g;s/"/\\"/g'\''')\"")' \
                --preview='${pkgs.bat}/bin/bat -- {1}' # Use your favorite previewer here (bat, source-highlight, etc.), for example:
        }}
      '';
      on-select = ''
        &{{
            ${pkgs.lf}/bin/lf -remote "send $id set statfmt \"$(${pkgs.eza}/bin/eza -ld --color=always "$f" | sed 's/\\/\\\\/g;s/"/\\"/g')\""
        }}
      '';
      on-cd = ''
        &{{
            fmt="$(STARSHIP_SHELL=${pkgs.starship}/bin/starship prompt | sed 's/\\/\\\\/g;s/"/\\"/g')"
            ${pkgs.lf}/bin/lf -remote "send $id set promptfmt \"$fmt\""
        }}
      '';
      open = ''
        &{{
          case $(file --mime-type -Lb $f) in
            text/*) ${pkgs.lf}/bin/lf -remote "send $id \$$EDITOR \$fx";;
            *) ${pkgs.xdg-utils}/bin/xdg-open "$f" > /dev/null 2> /dev/null;;
          esac
        }}
      '';
    };
    settings = {
      ifs = "\n";
      icons = true;
      kitty = true;
    };
    extraConfig =
      "set cleaner "
      + pkgs.writeShellScript "cleaner.sh" ''
        #!/bin/sh
        exec ${pkgs.kitty}/bin/kitten icat --clear --stdin no --transfer-mode memory </dev/null >/dev/tty
      '';
    previewer = {
      source = pkgs.writeShellScript "pv.sh" ''
        #!/bin/sh
        draw() {
          ${pkgs.kitty}/bin/kitten icat --stdin no --transfer-mode memory --place "''${w}x''${h}@''${x}x''${y}" "$1" </dev/null >/dev/tty
          exit 1
        }

        file="$1"
        w="$2"
        h="$3"
        x="$4"
        y="$5"

        case "$(${pkgs.file}/bin/file -Lb --mime-type -- "$1")" in
          image/*)
            draw "$file"
            exit 1
            ;;
        esac

        ${pkgs.pistol}/bin/pistol "$1"
      '';
    };
  };

  xdg.configFile = {
    "lf/colors" = {
      enable = true;
      source = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/gokcehan/lf/r32/etc/colors.example";
        hash = "sha256-cYJlXuRjuotQ1aynPG5+UGK2nBBNg/6xRiGs2mBpKeY=";
      };
    };
    "lf/icons" = {
      enable = true;
      source = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/gokcehan/lf/r32/etc/icons.example";
        hash = "sha256-PZxDReQhwEeDRvSeLFhjGjRAy+Yc3GTXXL6OLP23gQQ=";
      };
    };
  };
}
