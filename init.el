;; init.el --- Emacs configuration

;; INSTALL PACKAGES
;; --------------------------------------

(require 'package)

(add-to-list 'package-archives
       '("melpa" . "http://melpa.org/packages/") t)

(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents))

(defvar myPackages
  '(better-defaults
    elpy
    flycheck
    material-theme
    py-autopep8))

(mapc #'(lambda (package)
    (unless (package-installed-p package)
      (package-install package)))
      myPackages)

;; BASIC CUSTOMIZATION
;; --------------------------------------
(defalias 'yes-or-no-p 'y-or-n-p)
(setq auto-save-default nil)
(setq inhibit-startup-message t) ;; hide the startup message
(load-theme 'material t) ;; load material theme
(global-linum-mode t) ;; enable line numbers globally
(tool-bar-mode -1) ;;disable toolbar
(menu-bar-mode -1) ;;disable menu bar

;; for smart parenthesis 
(require 'smartparens-config)
(show-smartparens-global-mode +1)
(smartparens-global-mode 1)
(sp-pair "(" ")" :wrap "C-(")

(ivy-mode 1)

;; ;; autocomplete mit company
;; (add-hook 'after-init-hook 'global-company-mode)
;; (setq company-dabbrev-downcase 0)
;; (setq company-idle-delay 0)
;; (setq company-require-match nil)	

;; Python
;; ----------------------------------
(add-hook 'python-mode-hook (lambda() (flyspell-prog-mode))) ;; flyspell for mi baad inglisch
(elpy-enable)
(setq elpy-rpc-python-command "python3") ;;use python3
(setq python-shell-interpreter "python3");;use python3
(when (require 'flycheck nil t)
  (setq elpy-modules(delq 'elpy-module-flymake elpy-modules))
  (add-hook 'elpy-mode-hook 'flycheck-mode))
(require 'py-autopep8)
(add-hook 'elpy-mode-hook 'py-autopep8-enable-on-save)
;; elpy keybindings
(global-set-key (kbd "M-n") 'elpy-nav-forward-block)   ;;move bock down
(global-set-key (kbd "M-p") 'elpy-nav-backward-block)  ;;move bock up
(global-set-key (kbd "M-,") 'pop-tag-mark) ;; go to last place where M-. was used (go-to-definition)

;; C++
;; --------------------------
(setq c-default-style "linux"
      c-basic-offset 4
	  tab-width 4
	  indent-tabs-mode t)
;; flycheck
(require 'flycheck)
(add-hook 'c++-mode-hook
	  (lambda () (setq flycheck-clang-language-standard "c++11")))
(add-hook 'c++-mode-hook 'flycheck-mode)
;; rtags for references and shit
(add-hook 'c-mode-hook 'rtags-start-process-unless-running)
(add-hook 'c++-mode-hook 'rtags-start-process-unless-running)

(defun my-goto-symbol ()
  (interactive)
  (deactivate-mark)
  (ring-insert find-tag-marker-ring (point-marker))
  (or (and (require 'rtags nil t)
	   (rtags-find-symbol-at-point))))

(define-key global-map (kbd "M-.") 'my-goto-symbol)
(define-key global-map (kbd "M-,") 'pop-tag-mark)

;; cmake-ide
(require 'cmake-ide)
(cmake-ide-setup)
(setq cmake-ide-flags-c++ (append '("std=c++11")))
(global-set-key (kbd "C-c m") 'cmake-ide-compile)

;; yasnippet
(require 'yasnippet)
(yas-reload-all)
(add-hook 'c++-mode-hook #'yas-minor-mode)
(yas-global-mode 1)

;; irony for completion
(require 'irony)
(require 'company-irony-c-headers)
(add-hook 'c-mode-hook 'irony-mode)
(add-hook 'c++-mode-hook 'irony-mode)

(defun my-irony-mode-hook ()
  (define-key irony-mode-map
    [remap completion-at-point] 'irony-completion-at-point)
  (define-key irony-mode-map
    [remap complete-symbol] 'irony-completion-at-point))
(add-hook 'irony-mode-hook 'my-irony-mode-hook)
(add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)

(add-hook 'irony-mode-hook 'company-irony-setup-begin-commands)
(eval-after-load 'company '(add-to-list 'company-backends '(company-irony-c-headers
							    company-irony company-yasnippet
							    company-clang))) 

;; Latex
;; ---------------------------

(setq ispell-program-name "aspell")
(setq ispell-dictionary "german")
(add-hook 'LaTeX-mode-hook 'flyspell-mode)
(add-hook 'LaTeX-mode-hook 'flyspell-buffer)

(load "auctex.el" nil t t)

(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq TeX-save-query nil)

(setq TeX-PDF-mode t)

;; Make okular work
(setq TeX-source-correlate-mode t
      TeX-source-correlate-start-server t)
(eval-after-load "tex"
  '(setcar (cdr (assoc 'output-pdf TeX-view-program-selection)) "Okular"))


(defadvice auto-complete-mode (around disable-auto-complete-for-python)
  (unless (eq major-mode 'python-mode) ad-do-it))

(ad-activate 'auto-complete-mode)
(require 'auto-complete)
(add-to-list 'ac-modes 'latex-mode) ; beware of using 'LaTeX-mode instead
(require 'ac-math) ; package should be installed first 
(defun my-ac-latex-mode () ; add ac-sources for latex
  (setq ac-sources
        (append '(ac-source-math-unicode
          ac-source-math-latex
          ac-source-latex-commands)
                ac-sources)))
(add-hook 'LaTeX-mode-hook 'my-ac-latex-mode)
(setq ac-math-unicode-in-math-p t)
(ac-flyspell-workaround) ; fixes a known bug of delay due to flyspell (if it is there)

(require 'auto-complete-config) ; should be after add-to-list 'ac-modes and hooks
(ac-config-default)
(setq ac-auto-show-menu t)
;; (global-auto-complete-mode t) 
