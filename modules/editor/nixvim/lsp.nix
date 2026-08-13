{ ... }:

{
  programs.nixvim.plugins.lsp = {
    enable = true;
    servers = {
      nixd.enable = true;
      pyright.enable = true;
      jsonls.enable = true;
      html.enable = true;
      cssls.enable = true;
      ts_ls.enable = true;
      lua_ls.enable = true;

      rust_analyzer = {
        enable = true;
        package = null;
        installCargo = false;
        installRustc = false;
      };
    };
  };
}
