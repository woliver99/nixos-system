{ pkgs, ... }:

{
  programs.nixvim = {
    extraPackages = with pkgs; [
      nixfmt
      prettier
      black
      stylua
    ];

    plugins.conform-nvim = {
      enable = true;
      settings = {
        formatters_by_ft = {
          nix = [ "nixfmt" ];
          html = [ "prettier" ];
          css = [ "prettier" ];
          javascript = [ "prettier" ];
          json = [ "prettier" ];
          python = [ "black" ];
          lua = [ "stylua" ];
          
          # Installed per project
          astro = [ "prettier" ];
        };
      };
    };
  };
}
