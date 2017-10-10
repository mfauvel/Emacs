  ;; Keep track of loading time
  (defconst emacs-start-time (current-time))
  (require 'package)
  (package-initialize)

  (setq package-check-signature nil)
  (setq package-enable-at-startup nil)
  (setq package-archives '(("melpa" . "http://melpa.org/packages/")
                           ("org" . "http://orgmode.org/elpa/")
			   ("gnu" . "http://elpa.gnu.org/packages/")))

  (let ((elapsed (float-time (time-subtract (current-time) emacs-start-time))))
    (message "Loaded packages in %.3fs" elapsed))

  (require 'cl-lib)

(defvar mf/install-packages
  '(
    use-package
    ;;Editor configuration
    multiple-cursors
    cl-lib
    pdf-tools
    yasnippet
    helm-bibtex
    helm
    ivy
    swiper
    counsel
    move-text
    windmove
    neotree
    telephone-line
    monokai
    dired-quick-sort
    ;; Org mode
    org
    org-plus-contrib
    org-ref
    calfw
    org-gcal
    htmlize
    ;; Auctex
    auctex
    auto-complete-auctex
    bibtex
    reftex
    ;; Programming
    elpy
    find-file-in-project
    auto-complete
    magit
    focus
    ;; Misc
    emms
    wttrin
    gnuplot
    ;; Shell
    exec-path-from-shell
    )
  )

(defvar packages-refreshed? nil)

(dolist (pack mf/install-packages)
  (unless (package-installed-p pack)
    (unless packages-refreshed?
      (package-refresh-contents)
      (setq packages-refreshed? t))
    (unwind-protect
        (condition-case ex
            (package-install pack)
          ('error (message "Failed to install package [%s], caught exception: [%s]"
                           pack ex)))
      (message "Installed %s" pack))))
;; Load use-package, used for loading packages everywhere else
(require 'use-package)
;; Set to t to debug package loading
(setq use-package-verbose nil)

;; See brackets and so don
(show-paren-mode 1)
(setq show-paren-style 'mixed) ; highlight brackets if visible, else entire expression
(electric-pair-mode 1)

;; Set font
;;(set-face-attribute 'default nil :font "DejaVu Sans Mono-10")
(set-face-attribute 'default nil
		    :family "Source Code Pro"
		    :height 110
		    :weight 'normal
		    :width 'normal
		    )

;; Prevent the cursor from blinking
(blink-cursor-mode 0)

;; Remove messages that you don't read
(setq initial-scratch-message "")
(setq inhibit-startup-message t)

;; No sound !
(setq visible-bell t)

;; Init recentf
(setq recentf-auto-cleanup 'never)
(recentf-mode 1)
(setq recentf-max-menu-items 100)

;; I need my entire screen
(scroll-bar-mode 0)
(tool-bar-mode 0)
(menu-bar-mode 0)
(setq scroll-margin 3)

;; See the column number
(column-number-mode t)

;; Highlight current line
(when window-system (global-hl-line-mode))

;; Highlights things
(use-package volatile-highlights
:ensure t
:defer t
:config
  (volatile-highlights-mode t))

;; Upcase/Downcase region 
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)

;; Always (y or n)
(fset 'yes-or-no-p 'y-or-n-p)

;; Revert buffer (sometimes needed)
(global-set-key (kbd "<f5>") 'revert-buffer)

;; Emacs close confirmation
(setq kill-emacs-query-functions
      (cons (lambda () (yes-or-no-p "Really Quit Emacs? "))
	    kill-emacs-query-functions))

;; Overwrite selected text
(delete-selection-mode t)

;; kill-this-buffer
(global-set-key (kbd "C-x k") 'kill-this-buffer)

;; Split buffer vertically
(setq split-height-threshold nil)
(setq split-width-threshold 0)

;; comment un-comment region
(global-set-key (kbd "C-x c") 'comment-or-uncomment-region)

;; Theme
(use-package monokai-theme
  :ensure t
  :defer t
  :init
   (setq monokai-height-minus-1 1.0
        monokai-height-plus-1 1.0
        monokai-height-plus-2 1.0
        monokai-height-plus-3 1.0
        monokai-height-plus-4 1.0)
  )

;; Switch between theme
(setq cur-theme nil)
(defun cycle-theme ()
  "Cycle between dark theme and light theme"
  (interactive)
  (if cur-theme
      (progn
	(disable-theme 'monokai)
	(setq cur-theme nil)
	(set-face-attribute 'default nil
		    :family "Source Code Pro"
		    :height 110
		    :weight 'normal
		    :width 'normal
		    )
	)
    (progn
      (load-theme 'monokai t)
      (setq cur-theme t)
      (set-face-attribute 'default nil
		    :family "Source Code Pro"
		    :height 110
		    :weight 'normal
		    :width 'normal
		    )
      )
    )
  )
;; Bind this to C-x t
(global-set-key (kbd "C-x t") 'cycle-theme)

;; Linum-mode
(global-set-key (kbd "C-x n") 'linum-mode)

;; Move-text
(use-package move-text
  :ensure t
  :config (move-text-default-bindings)
  )

;; Resize window
(global-set-key (kbd "C-x {") 'shrink-window-horizontally)
(global-set-key (kbd "C-x }") 'enlarge-window-horizontally)
(global-set-key (kbd "C-x <down>") 'shrink-window)
(global-set-key (kbd "C-x <up>") 'enlarge-window)

;; ibuffer
(global-set-key (kbd "C-x C-b") 'ibuffer) ;; Use Ibuffer for Buffer List
(setq ibuffer-saved-filter-groups
      (quote (("default"
	       ("dired" (mode . dired-mode))
	       ("org" (name . "^.*org$"))

	       ("web" (or (mode . web-mode) (mode . js2-mode)))
	       ("shell" (or (mode . eshell-mode) (mode . shell-mode)))
	       ("mu4e" (name . "\*mu4e\*"))
	       ("Programming" (or
			       (mode . python-mode)
			       (mode . c++-mode)))
	       ("Tex" (mode . latex-mode))
               ("PDF" (name . "^.*pdf$"))
	       ("emacs" (or
			 (name . "^\\*scratch\\*$")
			 (name . "^\\*Messages\\*$")))
	       ))))
(add-hook 'ibuffer-mode-hook
	  (lambda ()
	    (ibuffer-auto-mode 1)
	    (ibuffer-switch-to-saved-filter-groups "default")))

;; don't show these
					;(add-to-list 'ibuffer-never-show-predicates "zowie")
;; Don't show filter groups if there are no buffers in that group
(setq ibuffer-show-empty-filter-groups nil)

;; Don't ask for confirmation to delete marked buffers
(setq ibuffer-expert t)

(use-package multiple-cursors
  :ensure t
  :defer t
  :ensure cl-lib
  :bind (("C-c m n" . mc/mark-next-like-this)
	 ("C-c m a" . mc/mark-all-like-this)
	 ("C-c m l" . mc/edit-lines))
  :config (progn
	    (provide 'init-multiple-cursors))
  )

(use-package telephone-line
  :config
  (setq telephone-line-lhs
        '((accent . (telephone-line-vc-segment
                     telephone-line-erc-modified-channels-segment
                     telephone-line-process-segment))
          (nil    . (telephone-line-minor-mode-segment
                     telephone-line-buffer-segment))))
  (setq telephone-line-rhs
        '((nil    . (telephone-line-misc-info-segment))
          (accent . (telephone-line-major-mode-segment))
          (evil   . (telephone-line-airline-position-segment))))
  (telephone-line-mode t)
  )

(setq coding-system-for-read 'utf-8)
(setq coding-system-for-write 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-language-environment "UTF-8")
(prefer-coding-system 'utf-8)

;; Standard location of personal dictionary
(add-hook 'mu4e-compose-mode-hook 'flyspell-mode)
(add-hook 'org-mode-hook 'flyspell-mode)
(add-hook 'latex-mode-hook 'flyspell-mode)
(add-hook 'LaTex-mode-hook 'flyspell-mode)
;; You should have aspell-fr and aspell-en packages installed
(let ((langs '("english" "francais")))
  (setq lang-ring (make-ring (length langs)))
  (dolist (elem langs) (ring-insert lang-ring elem)))
(defun cycle-ispell-languages ()
  (interactive)
  (let ((lang (ring-ref lang-ring -1)))
    (ring-insert lang-ring lang)
    (ispell-change-dictionary lang)))

(global-set-key [f1] 'cycle-ispell-languages)

(use-package dired
  :init (progn
  	  (setq dired-dwim-target t)
	  (setq dired-listing-switches "-alh")
          (put 'dired-find-alternate-file 'disabled nil)
	  (setq ls-lisp-dirs-first t)
  )
  :config (progn
	  (define-key dired-mode-map (kbd "RET") 'dired-find-alternate-file) ; was dired-advertised-find-file
	  (define-key dired-mode-map (kbd "^") (lambda () (interactive) (find-alternate-file ".."))))  ; was dired-up-directory
          
  )
(use-package dired-quick-sort
  :ensure t
  :config
  (dired-quick-sort-setup)
  )

(use-package counsel
  :ensure t
    :bind (
	 ("C-x C-f" . counsel-find-file)
	 ("C-x l" . counsel-locate)
	 ("M-x" . counsel-M-x)
	 ("M-y" . counsel-yank-pop)
         ("C-x r". counsel-recentf)
	 )  
  )
(use-package swiper
  :init   (ivy-mode 1)
  :ensure t
  :config
  (setq ivy-count-format "(%d/%d) ")
  (setq ivy-use-virtual-buffers t)
  ;; number of result lines to display
  (setq ivy-height 10)
  ;; does not count candidates
  (setq ivy-count-format "")
  ;; no regexp by default
  (setq ivy-initial-inputs-alist nil)
  ;; configure regexp engine.
  (setq ivy-re-builders-alist
	;; allow input not in order
        '((t   . ivy--regex-ignore-order)))
  (setq ivy-display-style 'fancy)
  :bind (
	 ("C-s". swiper)
	 ("C-r". swiper)
	 ("C-x b" . ivy-switch-buffer)
	 ("C-c j" . ivy-immediate-done)
  )
  )

(use-package pdf-tools
  :ensure t :ensure org-pdfview
  :defer t
  :init (pdf-tools-install)
  :config (progn 
	    (setq revert-without-query (quote (".*.pdf")))
	    (setq TeX-view-program-selection '((output-pdf "PDF Tools")))
	    )
  )

(use-package yasnippet
:config (yas-global-mode 1)
:defer t
)

(use-package exec-path-from-shell
  :config (progn
	    (setq exec-path-from-shell-check-startup-files nil)
	    (exec-path-from-shell-initialize)
	    (exec-path-from-shell-copy-env "PATH")
	    )
  )

(use-package htmlize
:ensure t
)

;; (use-package windmove
;;   :ensure t
;;   :config
;;   ;; use command key on Mac
;;   (windmove-default-keybindings 'super)
;;   ;; wrap around at edges
;;   (setq windmove-wrap-around t)
;;   )

(use-package neotree
  :ensure t
  :config   (global-set-key [f8] 'neotree-toggle)
  )

(use-package org
  :mode (("\\.org$" . org-mode))
  :ensure org-plus-contrib
  :defer t
  :bind (("C-c a". org-agenda)
	 ("C-c l" . org-store-link)
	 ("C-c c" . org-capture))
  :config (progn
	    (use-package org-install)
	    (use-package ox)
            (use-package ox-beamer)
            (use-package ox-odt)
	    (use-package ox-bibtex)
	    (use-package ox-extra)
            
	    (setq org-log-done t)
	    (setq org-startup-indented t)
	    (setq org-agenda-files (list "~/Documents/Org_Files/calendar.org"
                                     "~/Documents/Org_Files/todo.org"    
					 ))
                                         
	    (setq org-export-htmlize-output-type 'css)
	    (setq org-src-fontify-natively t)
	    (setq org-src-preserve-indentation t)
            (setq org-confirm-babel-evaluate nil)

	    (setq org-odt-data-dir "/usr/share/emacs/24.4/etc/org/")
            (setq org-odt-styles-file nil)
	    (org-babel-do-load-languages
	     'org-babel-load-languages
	     '((python . t)
	       (latex . t)
	       (shell . t)
	       (calc . t)
	       (ditaa .t)
               (C .t)
	       (octave .t)
               (org .t)
	       (lisp .t)))
	    (setq org-latex-listings 'minted)
	    (setq org-latex-minted-options
		  '(("fontsize" "\\footnotesize")("obeytabs" "true")("tabsize" "4")("bgcolor" "bg")))
	    ;; (setq org-latex-pdf-process 
	    ;; 	  (quote (
	    ;; 		  "pdflatex -interaction nonstopmode -shell-escape -output-directory %o %f" 
	    ;; 		  "biber $(basename %b)" 
	    ;; 		  "pdflatex -interaction nonstopmode -shell-escape -output-directory %o %f" 
	    ;; 		  "pdflatex -interaction nonstopmode -shell-escape -output-directory %o %f")))
	    (setq org-latex-pdf-process
		  '("latexmk -pdflatex='pdflatex -interaction nonstopmode -shell-escape' -pdf -bibtex -f %f"))
	    ;;(setq org-export-latex-listings t)
	    (add-to-list 'org-latex-classes
			 '("koma-article"
			   "\\documentclass{scrartcl}
                \\usepackage{array}
                \\usepackage[utf8]{inputenc}                   
                \\usepackage[T1]{fontenc}
                \\usepackage{lmodern}
                \\usepackage[normalem]{ulem}
                \\usepackage{booktabs}
                \\usepackage{amsmath,amssymb,amsthm}
                \\PassOptionsToPackage{hyphens}{url}
                \\usepackage{hyperref}\\hypersetup{colorlinks=true,hypertexnames=false}
                \\usepackage[osf,sc]{mathpazo}
                \\usepackage{booktabs}
                \\usepackage{graphicx}
                \\usepackage{csquotes}
                \\usepackage[usenames,dvipsnames]{xcolor}\\definecolor{bg}{rgb}{0.95,0.95,0.95}
                [NO-DEFAULT-PACKAGES]
                [EXTRA]"
			  ("\\section{%s}" . "\\section*{%s}")
			  ("\\subsection{%s}" . "\\subsection*{%s}")
			  ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
			  ("\\paragraph{%s}" . "\\paragraph*{%s}")
			  ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))
	   
	    (add-to-list 'org-latex-classes
			 '("ieeetran"
			   "\\documentclass{IEEEtran}
                \\usepackage{array}
                \\usepackage[utf8]{inputenc}                   
                \\usepackage[T1]{fontenc}
                \\usepackage{lmodern}
                \\usepackage[normalem]{ulem}
                \\usepackage{booktabs}
                \\usepackage{amsmath,amssymb,amsthm}
                \\PassOptionsToPackage{hyphens}{url}
                \\usepackage{hyperref}\\hypersetup{colorlinks=true,hypertexnames=false}
                \\usepackage{booktabs}
                \\usepackage{graphicx}
                \\usepackage{csquotes}

                \\usepackage[usenames,dvipsnames]{xcolor}\\definecolor{bg}{rgb}{0.95,0.95,0.95}
                [NO-DEFAULT-PACKAGES]
                [EXTRA]"
			   ("\\section{%s}" . "\\section*{%s}")
			   ("\\subsection{%s}" . "\\subsection*{%s}")
			   ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
			   ("\\paragraph{%s}" . "\\paragraph*{%s}")))
	    ;; Add onlyenv for beamer
	    (add-to-list 'org-beamer-environments-extra
               '("onlyenv" "O" "\\begin{onlyenv}%a" "\\end{onlyenv}"))
	    (add-to-list 'org-beamer-environments-extra
               '("visibleenv" "V" "\\begin{visibleenv}%a" "\\end{visibleenv}"))

	    ;; Add boldface beamer
	    (defun my-beamer-bold (contents backend info)
	      (when (eq backend 'beamer)
		(replace-regexp-in-string "\\`\\\\[A-Za-z0-9]+" "\\\\textbf" contents)))
	        
                (add-to-list 'org-export-filter-bold-functions 'my-beamer-bold)
	    ;; Remove hypersetup that sucks whith beamer
	    (setq org-latex-with-hyperref nil)

            ;; Multiple lines for emphasis
	    (setcar (nthcdr 4 org-emphasis-regexp-components) 3)
            (setcar (nthcdr 2 org-emphasis-regexp-components) " \t\n,")
            (custom-set-variables `(org-emphasis-alist ',org-emphasis-alist))
	    ;; Hide Marker
	    (setq org-hide-emphasis-markers t)
            
            ;; Use pdf-tools
            (set 'org-file-apps
		 (quote
		  ((auto-mode . emacs)
		   ("\\.pdf\\'" . org-pdfview-open))))
	    
	    ;; Set capture mode ORG-MODE
	    (setq org-capture-templates
		  '(("t" "Todo" entry (file+headline "~/Documents/Org_Files/todo.org" "Tasks")
		     "* %U %?\n")
		     ("c" "Calendar Pro" entry (file "~/Documents/Org_Files/calendar.org")
                     "* %?\n\n%^T\n\n:PROPERTIES:\n\n:END:\n\n")
		    ("w" "Daily" entry (file+datetree "~/Documents/Org_Files/dailywork.org")
		     "* %?\n:PROPERTIES:\n:PROJECT: \n:END:" :clock-in t :clock-keep t)
		    ("m" "Mail" entry (file+headline "~/Documents/Org_Files/todo.org" "Mails")
		     "* %U %?\n")))
	    

	    ;; System locale to use for formatting time values.
	    (setq system-time-locale "C")  ; Make sure that the weekdays in the
					; time stamps of your Org mode files and
					; in the agenda appear in English.

	    ;; prevent edit unseen text
	    (setq-default org-catch-invisible-edits 'show)

	    ;; Display image inline
	    (setq org-startup-with-inline-images t)
	    (setq org-image-actual-width 300)

	    ;; Export date correctly from: http://endlessparentheses.com/better-time-stamps-in-org-export.html
            (setq-default org-display-custom-times nil)
	    (setq org-time-stamp-custom-formats
	    	  '("<%A, %B %d, %Y>" . "<%A, %B %d, %Y %H:%M>"))

	    ;; ignore headlines  but include the text with the tab :ignore: usefull for the bibtex
	    (ox-extras-activate '(ignore-headlines))
	    )
  )

(use-package org-ref
  :ensure t
  :init (setq org-ref-completion-library 'org-ref-ivy-cite)
  :config ((setq reftex-default-bibliography '("/home/mfauvel/Documents/Recherche/ENSAT/Bibliographie/references.bib"))
	   (setq org-ref-bibliography-notes "/home/mfauvel/Documents/Recherche/ENSAT/Bibliographie/notes.org"
		 org-ref-default-bibliography '("/home/mfauvel/Documents/Recherche/ENSAT/Bibliographie/references.bib")
		 org-ref-pdf-directory "/home/mfauvel/Documents/Recherche/ENSAT/Bibliographie/bibtex-pdfs/")
	   (unless (file-exists-p org-ref-pdf-directory)
	     (make-directory org-ref-pdf-directory t))
	   
	     (setq helm-bibtex-pdf-open-function 'org-open-file)
	   )
  )

(use-package calfw
  :ensure t
  :bind (("C-c b" . cfw:open-calendar-buffer)
	 ("C-c o" . cfw:open-org-calendar))
  :config (progn
	    (use-package calfw-org)
            (setq cfw:org-capture-template nil
		  calendar-week-start-day 1
                  cfw:org-overwrite-default-keybinding t)
	    )
  )
(use-package org-gcal
  :ensure t
  :config (progn
	    (setq org-gcal-client-id "680696705562-lrj1fk1nha7i6squ4uolhvd4ikj4va72.apps.googleusercontent.com"
		  org-gcal-client-secret "QYyHhLMv8uprO0W9IPAg8Rge"
		  org-gcal-file-alist '(("mathieu.fauvel@gmail.com" .  "/home/mfauvel/Documents/Org_Files/calendar.org"))
	          org-gcal-down-days 360
	    	  org-gcal-up-days 30
		  )
	    )
  )
(add-hook 'org-agenda-mode-hook (lambda () (org-gcal-sync) ))
(add-hook 'org-capture-after-finalize-hook (lambda () (org-gcal-sync) ))
;;ID  680696705562-lrj1fk1nha7i6squ4uolhvd4ikj4va72.apps.googleusercontent.com
;; secret  eqo-Bh1VFGPy-yz2PdOLgVyI 4/Q_7-MLMMu-ecTIKXq8VAihLPXBaJKPx9tu6mt3_r1I8

(use-package auctex
  :ensure t
  :mode ("\\.tex\\'" . latex-mode)
  :commands (latex-mode LaTeX-mode plain-tex-mode)
  :init
  (progn
    (add-hook 'LaTeX-mode-hook #'LaTeX-preview-setup)
    (add-hook 'LaTeX-mode-hook #'visual-line-mode)
    (add-hook 'LaTeX-mode-hook #'flyspell-mode)
    (add-hook 'LaTeX-mode-hook #'LaTeX-math-mode)
    (add-hook 'LaTeX-mode-hook #'outline-minor-mode)
    (setq TeX-auto-save t)
    (setq TeX-parse-self t)
    (setq TeX-save-query nil)
    (setq TeX-PDF-mode t)     
    (setq LaTeX-command-style '(("" "%(PDF)%(latex) -shell-escape %S%(PDFout)")))
    (setq-default TeX-master nil)
    (setq outline-minor-mode-prefix "C-c C-o"))
  )

(use-package bibtex
  :mode ("\\.bib" . bibtex-mode)
  :init
  (progn
    (setq bibtex-align-at-equal-sign t)
    (add-hook 'bibtex-mode-hook (lambda () (set-fill-column 120)))))

(use-package reftex
  :commands turn-on-reftex
  :init (progn (setq reftex-plug-into-AUCTeX t))
  )

(use-package mu4e
  :load-path "/usr/local/share/emacs/site-lisp/mu4e"
  :bind (("C-x m" . mu4e))
  :defer t
  :config (progn
	    (use-package mu4e-contrib
	    :load-path "/usr/local/share/emacs/site-lisp/mu4e")
	    (use-package smtpmail
	      :load-path "/usr/local/share/emacs/site-lisp/mu4e")
	    (use-package org-mu4e
	      :load-path "/usr/local/share/emacs/site-lisp/mu4e")
	    (use-package org-eldoc
	      :load-path "/usr/local/share/emacs/site-lisp/mu4e")
	    (setq mu4e-maildir "~/Maildir")
	    (setq mu4e-sent-folder   "/sent")
	    (setq mu4e-drafts-folder "/drafts")
	    (setq mu4e-trash-folder  "/trash")
	    
	    ;; allow for updating mail using 'U' in the main view:
	    (setq mu4e-get-mail-command "offlineimap")
	    
	    ;; show full addresses in view message (instead of just names)
	    ;; toggle per name with M-RET
	    (setq mu4e-view-show-addresses t)
	    
	    ;; set IMAP and update
	    (setq
	     mu4e-get-mail-command "offlineimap"   ;;
	     mu4e-update-interval 300)             ;; update every 5 minutes
	    
	    ;; something about ourselves
	    (setq mu4e-user-mail-address-list
		  '(
		    "mathieu.fauvel@ensat.fr"
		    )
		  user-mail-address "mathieu.fauvel@ensat.fr"
		  mu4e-reply-to-address "mathieu.fauvel@ensat.fr"
		  user-full-name  "Mathieu Fauvel"
		  mu4e-compose-signature
		  (concat
		   "Fauvel Mathieu
Director of the Engineering and Numerical Sciences Department
Associated Editor IEEE Journal of Selected Topics in Applied Earth Observations and Remote Sensing
Coordinator of the European IEEE GRSS Chapters

http://fauvel.mathieu.free.fr

INP - ENSAT - DYNAFOR
Avenue de l'Agrobiopole
31326 Castanet-Tolosan, FRANCE.
Phone: +33(0)5 34 32 39 22
"))
	    (setq message-send-mail-function 'smtpmail-send-it
		  starttls-use-gnutls t
		  smtpmail-starttls-credentials '(("mail.inp-toulouse.fr" 587 nil nil))
		  smtpmail-auth-credentials
		  '(("mail.inp-toulouse.fr" 587 "mfauvel" nil))
		  smtpmail-default-smtp-server "mail.inp-toulouse.fr"
		  smtpmail-smtp-server "mail.inp-toulouse.fr"
		  smtpmail-smtp-service 587
		  smtpmail-queue-mail  nil
		  smtpmail-queue-dir  "~/Maildir/queue/cur")
	    
					; don't keep message buffers around
	    (setq message-kill-buffer-on-exit t)
	    (setq mu4e-view-prefer-html t)
	    (setq mu4e-compose-dont-reply-to-self t)

	    ;; Only to reflow my paragraphs
	    (setq mu4e-compose-format-flowed t)

	    (add-hook 'mu4e-view-mode-hook
		      (lambda()
			;; try to emulate some of the eww key-bindings
			(local-set-key (kbd "<tab>") 'shr-next-link)
			(local-set-key (kbd "<backtab>") 'shr-previous-link)))
	    
	    (add-to-list 'mu4e-view-actions
			 '("View in browser" . mu4e-action-view-in-browser) t)
	    
	    ;; make the `gnus-dired-mail-buffers' function also work on
	    ;; message-mode derived modes, such as mu4e-compose-mode
	    (defun gnus-dired-mail-buffers ()
	      "Return a list of active message buffers."
	      (let (buffers)
		(save-current-buffer
		  (dolist (buffer (buffer-list t))
		    (set-buffer buffer)
		    (when (and (derived-mode-p 'message-mode)
			       (null message-sent-message-via))
		      (push (buffer-name buffer) buffers))))
		(nreverse buffers)))
	    
	    (setq gnus-dired-mail-mode 'mu4e-user-agent)
	    (add-hook 'dired-mode-hook 'turn-on-gnus-dired-mode)
	    
	    (setq mu4e-compose-keep-self-cc nil)
	    
	    ;; when mail is sent, automatically convert org body to HTML
	    (setq org-mu4e-convert-to-html t)
	    ;; need this to convert some e-mails properly
	    (setq mu4e-html2text-command "w3m -I utf8 -O utf8 -T text/html")
	    
	    (setq mu4e-msg2pdf "/usr/bin/msg2pdf")

	    ;; Add org table and org list structures to the message mode
	    (add-hook 'message-mode-hook 'turn-on-orgtbl)
	    (add-hook 'message-mode-hook 'turn-on-orgstruct++)

	    ;; Multiple attachments
	    (setq mu4e-save-multiple-attachments-without-asking t)
	    
	    )
  )

(use-package elpy
  :ensure t
  :config (progn
	    (elpy-enable)
	    (elpy-use-ipython)
	    )
  )
(setenv "PYTHONPATH" (shell-command-to-string "$SHELL -i -c 'echo $PYTHONPATH'"))

(use-package auto-complete
  :ensure t
  :init (progn
  (ac-config-default)
  (global-auto-complete-mode t)
  )
  )

(use-package magit
  :ensure t
  :defer t
  :bind (("C-x g". magit-status)
  )
)

(use-package hideshow
  :ensure t
  :defer t
  :bind (("C-c <left>" . hs-toggle-hiding)
	 ("C-c <right>" . hs-show-block)
	 )
  :init (add-hook 'prog-mode-hook #'hs-minor-mode)
  )

(use-package focus
  :ensure t
  :defer t
  :bind (("C-c f" . focus-mode))
  )

(use-package emms
  :ensure t
  :defer t
  :config (progn 
	    (emms-all)
	    (emms-default-players)
	    )
  )

(use-package wttrin
  :ensure t
  :defer t
  :commands (wttrin)
  :bind (("C-x w". wttrin))
  :init
  (setq wttrin-default-cities '("Toulouse"
                                "Vicdessos")))
