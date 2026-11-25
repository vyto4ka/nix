{ pkgs, ... }:
{
  home.packages = with pkgs; [
    libreoffice
    hunspell
    hunspellDicts.ru_RU
    kdePackages.okular
    pdfarranger
    xournalpp
    thunderbird
  ];
}
