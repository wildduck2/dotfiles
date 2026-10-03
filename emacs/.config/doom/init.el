;;; init.el -*- lexical-binding: t; -*-

;; This file controls what Doom modules are enabled and what order they load
;; in. Remember to run 'doom sync' after modifying it.

(doom! :input

       :completion
       (corfu +orderless +icons)
       (vertico +icons)

       :ui
       doom
       doom-dashboard
       hl-todo
       indent-guides
       modeline
       nav-flash
       ophints
       (popup +defaults)
       treemacs
       vc-gutter
       vi-tilde-fringe
       window-select
       workspaces

       :editor
       (evil +everywhere)
       file-templates
       fold
       multiple-cursors
       snippets

       :emacs
       dired
       electric
       undo
       vc

       :term
       vterm

       :checkers
       syntax
       (spell +flyspell)

       :tools
       direnv
       editorconfig
       (eval +overlay)
       (lookup +dictionary +docsets)
       (lsp +peek)
       magit
       make
       tree-sitter

       :os
       ;;tty

       :lang
       (cc +lsp +tree-sitter)
       data
       emacs-lisp
       (elixir +lsp +tree-sitter)
       (javascript +lsp +tree-sitter)
       (json +lsp)
       markdown
       (org +pretty)
       (rust +lsp +tree-sitter)
       (sh +lsp)
       (web +lsp)
       yaml

       :email

       :app

       :config
       (default +bindings +smartparens))
