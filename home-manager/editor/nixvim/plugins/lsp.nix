{pkgs, ...}: let
  vue-language-server = pkgs.vue-language-server.override {
    nodejs-slim_latest = pkgs.nodejs-slim;
  };
in {
  programs.nixvim.plugins = {
    lsp = {
      enable = true;
      inlayHints = true;
      servers = {
        ts_ls.enable = true;
        svelte.enable = true;
        vue_ls = {
          enable = true;
          package = vue-language-server;
        };
        nil_ls.enable = true;
        clangd.enable = true;
        gopls = {
          enable = true;
          settings = {
            hints = {
              compositeLiteralFields = true;
              constantValues = true;
              parameterNames = true;
            };
          };
        };
        eslint.enable = true;
        tailwindcss.enable = true;
        html.enable = true;
        jsonls.enable = true;
        phpactor.enable = true;
        rust_analyzer = {
          enable = true;
          installCargo = false;
          installRustc = false;
        };
      };
    };
  };
}
