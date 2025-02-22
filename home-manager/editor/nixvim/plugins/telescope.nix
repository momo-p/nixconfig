{
  programs.nixvim.plugins = {
    telescope = {
      enable = true;
      keymaps = {
        "<leader><leader>" = "buffers";
        "<leader>ff" = "find_files";
        "<leader>fg" = "live_grep";
        "<leader>git" = {
          action = "git_files";
          options = {
            desc = "Telescope Git Files";
          };
        };
      };
      extensions = {
        ui-select = {
          enable = true;
        };
      };
    };
  };
}
