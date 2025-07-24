{
  programs.nixvim = {
    globals = {
      mapleader = " ";
    };
    keymaps = [
      {
        action = ":Neotree toggle<CR>";
        key = "<leader>n";
      }
      {
        action = ":Neotree focus<CR>";
        key = "<leader>nn";
      }
      {
        action = "<cmd>lua vim.diagnostic.open_float()<CR>";
        key = "<leader>g";
      }
    ];
  };
}
