{
  programs.nixvim.plugins = {
    treesitter = {
      enable = true;
      settings = {
        auto_install = true;
        highlight = {
          additional_vim_regex_highlighting = true;
          custom_captures = {};
          enable = true;
        };

        incremental_selection = {
          enable = true;
          keymaps = {
            init_selection = "gnn";
            node_decremental = "grm";
            node_incremental = "grn";
            scope_incremental = "grc";
          };
        };
        indent = {
          enable = true;
        };
      };
    };
  };
}
