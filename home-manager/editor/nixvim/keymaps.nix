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
    ];
  };
}
