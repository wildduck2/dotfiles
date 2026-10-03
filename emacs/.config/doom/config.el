;;; config.el -*- lexical-binding: t; -*-

;; Literate config -- the real source is config.org. Tangled to a cache file
;; (never back into this file -- `org-babel-load-file' tangles to a file with
;; the same basename as its source, and since this file is a stowed symlink
;; into the dotfiles repo, that would silently overwrite the tracked source
;; on every startup) and loaded fresh each time, so editing config.org *is*
;; editing the config.
(let ((org-file (expand-file-name "config.org" doom-user-dir))
      (tangled-file (expand-file-name "config.org.el" doom-cache-dir)))
  (require 'ob-tangle)
  (org-babel-tangle-file org-file tangled-file "emacs-lisp")
  (load tangled-file))
