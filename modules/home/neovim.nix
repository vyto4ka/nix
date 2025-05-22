{ config, pkgs, lib, ... }:
{
  programs.neovim = {
    enable = true;
    extraPackages = with pkgs; [
      git
      lua-language-server
      stylua
      ripgrep
    ];
    plugins = with pkgs.vimPlugins; [ lazy-nvim ];
    extraLuaConfig = ''
      local plugins = {
        -- LazyVim core
        { "LazyVim/LazyVim", import = "lazyvim.plugins" },
        -- Telescope FZF native
        { "nvim-telescope/telescope-fzf-native.nvim", enabled = true },
        -- Disable Mason (managed by Nix)
        { "williamboman/mason-lspconfig.nvim", enabled = false },
        { "williamboman/mason.nvim", enabled = false },
        -- Ensure no auto Tree-sitter installs
        { "nvim-treesitter/nvim-treesitter", opts = { ensure_installed = {} } },
      }
      require("lazy").setup({
        spec = plugins,
        defaults = { lazy = true },
        dev = { path = vim.fn.stdpath("config") .. "/lazy-plugins", patterns = {}, fallback = true },
      })
    '';
  };
}
