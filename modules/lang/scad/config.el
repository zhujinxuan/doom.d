;;; lang/scad/config.el -*- lexical-binding: t; -*-
(use-package! scad-mode
  :mode "\\.scad\\'"
  :commands (scad-mode lsp-mode)
  :config
  (setq-default scad-command "~/.nix-profile/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD")
  )
