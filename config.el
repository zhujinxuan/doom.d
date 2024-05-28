;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Jinxuan Zhu"
      user-mail-address "zhujinxuan@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
(setq doom-font (font-spec :family "Fira Code" :size 16 :weight 'normal)
      doom-variable-pitch-font (font-spec :family "Fira Code" :size 16))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; Integrate org-journal with agenda
(setq org-journal-enable-agenda-integration t)

;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; (add-to-list 'auto-mode-alist '("\\.tsx\\'" . typescript-mode))

(use-package! treemacs
  :config
  (setq treemacs-follow-after-init t)
  (treemacs-follow-mode t)
  )

(use-package! evil-snipe
  :config
  (setq evil-snipe-scope 'whole-visible)
  )

(defun org-journal-find-location ()
  ;; Open today's journal, but specify a non-nil prefix argument in order to
  ;; inhibit inserting the heading; org-capture will insert the heading.
  (org-journal-new-entry t)
  (unless (eq org-journal-file-type 'daily)
    (org-narrow-to-subtree))
  (goto-char (point-max)))


(use-package! lsp
  :config
  (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]vendor\\'")
  (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]node_modules\\'")
  (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]build\\'")
  )
(use-package! org-journal
  :config
  (setq
   org-journal-dir "~/org/journal/"
   org-journal-file-format "%Y-%m-%d"
   org-journal-date-prefix "#+TITLE: "
   org-journal-date-format "%A, %B %d %Y"
   org-journal-time-prefix "** "
   org-journal-carryover-items "-daily+TODO=\"TODO\"|keep"
   )
  (setq org-capture-templates
        (mapcar (lambda (template)
                  (cond ((equal "j" (car template))
                         '( "j" "Journal entry" entry (function org-journal-find-location)
                            "* TODO %?\n%l\n%i"
                            :prepend t
                            :jump-to-captured t
                            :immediate-finish t
                            ))
                        (t template))
                  )
                org-capture-templates)
        )
  )
(defun pc/new-buffer-p ()
  (not (file-exists-p (buffer-file-name))))
(defun pc/insert-journal-template ()
  (let ((template-file (expand-file-name "templates/daily.org" org-directory)))
    (when (pc/new-buffer-p)
      (save-excursion
        (goto-char (point-max))
        (beginning-of-line)
        (insert-file-contents template-file)
        (newline-and-indent)
        ))))
(add-hook 'org-journal-after-entry-create-hook #'pc/insert-journal-template)

(setq-default ispell-aspell-data-dir "~/.nix-profile/lib/aspell")
(setq-default ispell-aspell-dict-dir "~/.nix-profile/lib/aspell")
(setq-default ledger-binary-path "~/.nix-profile/bin/hledger")

(use-package! ledger-mode
  :config
  (set-company-backend! 'ledger-mode 'company-dabbrev)
  )

(add-to-list 'auto-mode-alist '("\\.timeclock\\'" . ledger-mode))
(setq yas-snippet-dirs (append yas-snippet-dirs
                               '("~/.doom.d/snippets"))) ;; replace with your folder for snippets

(defun yas/new-timeclock-last-line ()
  "Save Last Line"
  (let ((last-line-text (save-excursion
                          (beginning-of-line 0)
                          (thing-at-point 'line t)
                          ))
        )

    (list
     (concat "i" (string-remove-prefix "o" (string-trim last-line-text) ))
     last-line-text)
    )

  )
(setq-default org-babel-load-languages '((restclient . t) (emacs-lisp . t)))
(defun synchronize-theme ()
  "Synchronize theme based on the sun rise and sun set."
  (interactive)
  (let* ((light-theme 'doom-one-light)
         (dark-theme 'doom-one)
         (start-time-light-theme 6)
         (end-time-light-theme 18)
         (hour (string-to-number (substring (current-time-string) 11 13)))
         (next-theme (if (member hour (number-sequence start-time-light-theme end-time-light-theme))
                         light-theme dark-theme)))
    (when (not (equal doom-theme next-theme))
      (setq doom-theme next-theme)
      (load-theme next-theme))))

(run-with-timer 0 3600 'synchronize-theme)


(set-formatter! 'prettier-php  '(npx "prettier" "--stdin-filepath" filepath "--parser=php"
                                 (apheleia-formatters-js-indent "--use-tabs" "--tab-width")) :modes '(php-mode))

;; (after! lsp-haskell
;;   (setq lsp-haskell-formatting-provider "fourmolu"))
