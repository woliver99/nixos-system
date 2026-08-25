{ config, lib, ... }:

let
  cfg = config.maple.profiles.neovim;
  nixvim = import ../../../pkgs/nixvim;
in
{
  imports = [
    nixvim.nixosModules.nixvim
    ./common.nix
    ./lsp.nix
    ./formatters.nix
  ];

  options.maple.profiles.neovim = {
    enable = lib.mkEnableOption "Neovim with sane defaults.";
  };

  config = lib.mkIf cfg.enable {
    programs.nixvim = {
      enable = cfg.enable;

      extraConfigLua = ''
        local function paste()
          return {vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("")}
        end

        vim.g.clipboard = {
          name = 'native-osc52',
          copy = {
            ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
            ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
          },
          paste = {
            ['+'] = paste,
            ['*'] = paste,
          },
        }

        vim.opt.clipboard:append("unnamedplus")
      '';
    };
  };
}
