;;; package --- Summary
;;; Commentary:
;; This is init Emacs of Anurag Peshne, This is how I roll.
;;; Code:

;; bump up garbage collection threshold; will restore this at the end
;; backup value
(defvar gc-cons-threshold-bk)
(setq gc-cons-threshold-bk gc-cons-threshold)
(setq gc-cons-threshold (* 100 1024 1024))

;; org-babel elixir functions
(add-to-list 'load-path "~/.emacs.d/ob-elixir/")

(setq exec-path (append exec-path '("/usr/local/bin")))
(setenv "PATH" (concat (concat (getenv "PATH") ":/usr/local/bin") ":/Library/TeX/texbin"))
(setq user-full-name "Anurag Peshne"
      user-mail-address "anurag.peshne@gmail.com")

(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(package-initialize)
(when (not package-archive-contents) (package-refresh-contents))

;; are we on mac?
(defvar is-mac)
(defvar is-linux)
(setq is-mac (equal system-type "darwin"))
(setq is-linux (equal system-type "gnu/linux"))

;; are we on powerful enough machine to load fancy modules?
(defvar is-power-machine t)

;; why say yes when y is enough
(fset 'yes-or-no-p 'y-or-n-p)

(setq use-package-verbose t)
;; Bootstrap `use-package'
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(setq savehist-file "~/.emacs.d/savehist")
(savehist-mode 1)
(setq history-length t)
(setq history-delete-duplicates t)
(setq savehist-save-minibuffer-history 1)
(setq savehist-additional-variables
      '(kill-ring
        search-ring
        regexp-search-ring))

(use-package winner
  :ensure t
  :defer t
  :init (winner-mode 1))

(use-package company
  :if is-power-machine
  :ensure t
  :defer t
  :diminish company-mode
  :init (add-hook 'after-init-hook 'global-company-mode))

(use-package dumb-jump
  :defer 3
  :bind ("C-M-g" . dumb-jump-go))

(use-package flycheck
  :if is-power-machine
  :ensure t
  :defer 5
  :diminish flycheck-mode
  :init (global-flycheck-mode))

(use-package helm
  :ensure t
  :diminish helm-mode
  :init
  (progn
    (require 'helm-config)
    (setq helm-candidate-number-limit 100)
    ;; From https://gist.github.com/antifuchs/9238468
    (setq helm-idle-delay 0.0 ; update fast sources immediately (doesn't).
          helm-input-idle-delay 0.01  ; this actually updates things
                                        ; reeeelatively quickly.
          helm-yas-display-key-on-candidate t
          helm-quick-update t
          helm-M-x-requires-pattern nil
          helm-ff-skip-boring-files t
          helm-M-x-fuzzy-match t
          helm-lisp-completion-at-point t
          helm-autoresize-mode t)
    (helm-mode 1))
  :bind (("C-x C-f" . helm-find-files)
         ("M-x" . helm-M-x)))

(use-package smart-mode-line
  :ensure t
  :init
  (progn
    (setq sml/theme 'respectful)
    (setq sml/no-confirm-load-theme t)
  :config
  (sml/setup)
  (add-to-list 'sml/replacer-regexp-list '("^~/Documents/brainDump/" ":brainDump:") t)
  (add-to-list 'sml/replacer-regexp-list '("^~/code/" ":code:") t)
  ;; note we have omitted trailing 't', to override in build :doc:
  (add-to-list 'sml/replacer-regexp-list '("^~/:Doc:/notes/" ":notes:"))))

(use-package ledger-mode
  :mode "\\.dat\\'")

(use-package smart-mode-line-powerline-theme
  :ensure t
  :config)

(use-package evil
  :ensure t
  :demand
  :init
  (progn
    (setq evil-want-C-u-scroll t)
    ;; Change cursor color depending on mode
    (setq evil-emacs-state-cursor '("red" box)
          evil-normal-state-cursor '("green" box)
          evil-visual-state-cursor '("orange" box)
          evil-insert-state-cursor '("red" bar)
          evil-replace-state-cursor '("red" bar)
          evil-operator-state-cursor '("red" hollow)))
  :config
  (evil-mode))

(use-package evil-vimish-fold
  :ensure t
  :defer t
  :diminish evil-vimish-fold-mode
  :init
  (evil-vimish-fold-mode 1)
  (define-key evil-normal-state-map (kbd "TAB") 'vimish-fold-toggle))

(use-package magit :ensure t :defer 5)

(use-package ace-jump-mode
  :defer t
  :diminish ace-jump-mode
  :init
  (define-key evil-normal-state-map (kbd "SPC") 'ace-jump-mode))

;; highlight changes
(use-package git-gutter-fringe
  :if is-power-machine
  :ensure t
  ;:defer 5
  :diminish git-gutter-mode
  :config (global-git-gutter-mode))

(use-package dracula-theme
  :ensure t
  :defer
  :init (load-theme 'dracula t))

(use-package zenburn-theme
  :ensure t
  :defer)
  ;:init (load-theme 'zenburn t))

(use-package leuven-theme :defer :disabled t)

(use-package linum-relative
  :ensure t
  :defer 2
  :init
  (progn
    (global-linum-mode t)
    (linum-relative-mode t)))

(column-number-mode 1)
(hl-line-mode 1)

(use-package cider-mode
  :mode "\\.clj\\'"
  :defer t)

(use-package clojure-mode
  :mode "\\.clj\\'"
  :defer t)

(use-package tex
  :defer t
  :ensure auctex
  :config
  (progn
    (add-hook 'LaTeX-mode-hook 'outline-minor-mode)
    (require 'outline-magic)
    (setq TeX-auto-save t)))

(use-package outline-magic
    :defer t
    :ensure
    :config
    (progn
      (require 'outline-magic)
      (define-key outline-minor-mode-map (kbd "<C-tab>") 'outline-cycle)))

(use-package projectile
    :diminish projectile-mode
    :defer 2
    :init
    (setq projectile-keymap-prefix (kbd "C-c C-p"))
    :config
    (progn
      (projectile-global-mode)
      (helm-projectile-on)
      (define-key projectile-mode-map [?\s-f] 'projectile-find-file)
      (define-key projectile-mode-map [?\s-t] 'projectile-find-test-file)))

;; look and appearance
(global-font-lock-mode t)
(show-paren-mode 1)
(prefer-coding-system 'utf-8)
;; use a nice font by default
;;(when is-mac
;;  (set-frame-font "-apple-Monaco-medium-normal-normal-*-12-*-*-*-m-0-fontset-auto1"))

(use-package whitespace
  :defer 2
  :config
  (progn
    (add-hook 'before-save-hook 'delete-trailing-whitespace)
    (setq-default show-trailing-whitespace t)
    (setq whitespace-style '(face empty tabs lines-tail trailing))
    (global-whitespace-mode t)))

(setq-default indent-tabs-mode nil) ;; use space for indentation
(setq-default tab-width 2) ;; or any other preferred value
(setq tab-stop-list (number-sequence 2 200 2))
(setq indent-line-function 'insert-tab)
(defvaralias 'c-basic-offset 'tab-width)
(defvaralias 'cperl-indent-level 'tab-width)

(setq case-fold-search t
      search-highlight t
      query-replace-highlight t
      fill-column 80
      make-backup-files nil
      ispell-dictionary "english"
      transient-mark-mode t
      show-paren-delay 0)
(delete-selection-mode 1)

;; good looking symbols
(defun my-add-pretty-lambda ()
"Make some word or string show as pretty Unicode symbols."
(setq prettify-symbols-alist
        '(
          ("lambda" . 955) ; λ
          ("->" . 8594)    ; →
          ("=>" . 8658)    ; ⇒
          ("map" . 8614)   ; ↦
          )))

(add-hook 'scheme-mode-hook 'my-add-pretty-lambda)
(add-hook 'tex-mode-hook 'my-add-pretty-lambda)

;; nice parentheses
(show-paren-mode t)
(setq show-paren-style 'expression)

(define-key global-map (kbd "RET") 'newline-and-indent)

;; faster buffer switch
(define-prefix-command 'vim-buffer-jump)
(global-set-key (kbd "C-w") 'vim-buffer-jump)
(define-key vim-buffer-jump (kbd "<left>") 'windmove-left)
(define-key vim-buffer-jump (kbd "<right>") 'windmove-right)
(define-key vim-buffer-jump (kbd "<up>") 'windmove-up)
(define-key vim-buffer-jump (kbd "<down>") 'windmove-down)

;; reload files automatically when changed on disk
(global-auto-revert-mode t)

(setq tramp-default-method "ssh")

(add-to-list 'auto-mode-alist '("\\.log\\'" . auto-revert-mode))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector
   ["#3F3F3F" "#CC9393" "#7F9F7F" "#F0DFAF" "#8CD0D3" "#DC8CC3" "#93E0E3" "#DCDCCC"])
 '(custom-safe-themes
   (quote
    ("9a155066ec746201156bb39f7518c1828a73d67742e11271e4f24b7b178c4710" "412c25cf35856e191cc2d7394eed3d0ff0f3ee90bacd8db1da23227cdff74ca2" "ff02e8e37c9cfd192d6a0cb29054777f5254c17b1bf42023ba52b65e4307b76a" "70b9c3d480948a3d007978b29e31d6ab9d7e259105d558c41f8b9532c13219aa" "20e359ef1818a838aff271a72f0f689f5551a27704bf1c9469a5c2657b417e6c" "f5eb916f6bd4e743206913e6f28051249de8ccfd070eae47b5bde31ee813d55f" "26614652a4b3515b4bbbb9828d71e206cc249b67c9142c06239ed3418eff95e2" "3c83b3676d796422704082049fc38b6966bcad960f896669dfc21a7a37a748fa" default)))
 '(fci-rule-color "#383838")
 '(ledger-reports
   (quote
    (("discover" "ledger -f ~/Documents/ledgers/fy2018.dat bal dis")
     ("wf" "ledger -f ~/Documents/ledgers/fy2018.dat bal sav che")
     ("splitwise" "ledger -f ~/Documents/ledgers/fy2018.dat bal split")
     ("bal" "%(binary) -f %(ledger-file) bal")
     ("reg" "%(binary) -f %(ledger-file) reg")
     ("payee" "%(binary) -f %(ledger-file) reg @%(payee)")
     ("account" "%(binary) -f %(ledger-file) reg %(account)"))))
 '(nrepl-message-colors
   (quote
    ("#CC9393" "#DFAF8F" "#F0DFAF" "#7F9F7F" "#BFEBBF" "#93E0E3" "#94BFF3" "#DC8CC3")))
 '(package-selected-packages
   (quote
    (clojure-snippets yasnippet yasnippet-snippets latex-extra slime ledger-mode helm-projectile projectile markdown-mode web-mode alchemist flycheck-elixir outline-magic-mode outline-magic auctex company company-mode zenburn-theme use-package smart-mode-line-powerline-theme magit linum-relative leuven-theme htmlize helm git-gutter-fringe flycheck evil-vimish-fold dumb-jump cider ag ace-jump-mode)))
 '(send-mail-function (quote mailclient-send-it))
 '(vc-annotate-background "#2B2B2B")
 '(vc-annotate-color-map
   (quote
    ((20 . "#BC8383")
     (40 . "#CC9393")
     (60 . "#DFAF8F")
     (80 . "#D0BF8F")
     (100 . "#E0CF9F")
     (120 . "#F0DFAF")
     (140 . "#5F7F5F")
     (160 . "#7F9F7F")
     (180 . "#8FB28F")
     (200 . "#9FC59F")
     (220 . "#AFD8AF")
     (240 . "#BFEBBF")
     (260 . "#93E0E3")
     (280 . "#6CA0A3")
     (300 . "#7CB8BB")
     (320 . "#8CD0D3")
     (340 . "#94BFF3")
     (360 . "#DC8CC3"))))
 '(vc-annotate-very-old-color "#DC8CC3"))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )


;; custom language hooks
(add-hook 'javascript-mode-hook
          (function (lambda ()
                      (setq indent-tabs-mode nil
                            tab-width 2))))

;; org mode settings
(setq org-directory "~/Documents/brainDump")
(use-package org
  :defer t
  :bind
  (("\C-cl" . org-store-link)
   ("\C-ca" . org-agenda))
  :init
  (progn
    (setq org-log-done 'time)
    (setq org-src-fontify-natively t))
  :config
  (progn
    (when (file-accessible-directory-p org-directory)
          (setq org-todo-keywords
                '((sequence "TODO(t)" "IN-PROGRESS(i)" "WAITING(w)" "|")
                  (sequence "DONE(d)" "CANCELLED(c)" "DELEGATED(d)")))
          (setq org-archive-location (concat org-directory "archive"))
          (setq org-agenda-files (list (concat org-directory "/currentMonth.org")
                                       (concat org-directory "/remember.org")))
          ;; setup remember (org-capture)
          (define-key global-map "\C-cc" 'org-capture)
          (setq org-default-notes-file (concat org-directory "/remember.org"))
          (setq org-capture-templates
                '(("t" "Todo" entry (file+headline (concat org-directory "/remember.org")
                                                   "Tasks")
                   "* TODO %?\n  %i\n  %a")
                  ("d" "ToDoD" entry (file+headline (concat org-directory "/currentMonth.org")
                                                    "/Remember/ Tasks")
                   "\n\n** TODO %?\n  DEADLINE: <%(org-read-date nil nil \"+2d\")>\n  %a")
                  ("j" "Journal" entry (file+datetree (concat org-directory "journal.org"))
                   "* %?\nEntered on %U\n  %i\n  %a")))
          (setq org-agenda-skip-scheduled-if-done t)
          (setq org-agenda-skip-deadline-if-done t)
          (setq org-agenda-skip-timestamp-if-done t)
          (setq org-clock-persist 'history)
          (org-clock-persistence-insinuate))
    (when is-power-machine
      (when is-mac
        (add-hook 'org-mode-hook 'ispell-minor-mode))
      (when is-linux
        (add-hook 'org-mode-hook 'aspell-minor-mode)))))
(org-babel-do-load-languages
  'org-babel-load-languages '((C . t)(python . t)(elixir . t)(ditaa . t)(clojure . t)))
(setq org-export-babel-evaluate nil)

(when (file-accessible-directory-p org-directory)
      (setq inhibit-splash-screen t)
      (org-agenda-list)
      (delete-other-windows))

(when window-system
  (tooltip-mode -1)
  (tool-bar-mode -1)
  (scroll-bar-mode -1))
(menu-bar-mode -1)
(set-frame-parameter nil 'fullscreen 'fullboth)

(when is-mac
  (setq ispell-program-name "/usr/local/bin/ispell"))

(when is-linux
  (setq ispell-program-name "/usr/bin/aspell"))

(setq sql-mysql-program "/usr/local/mysql/bin/mysql")

;; Restore gc-cons-threshold
(setq gc-cons-threshold gc-cons-threshold-bk)

;;; init.el ends here
