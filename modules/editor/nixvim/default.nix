{ pkgs, ... }:

{
  imports = [
    ./common.nix
  ];

  programs.nixvim = {
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
}
