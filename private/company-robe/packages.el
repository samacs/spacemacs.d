;;; packages.el --- company-robe layer packages file for Spacemacs.
;;
;; Copyright (c) 2012-2017 Sylvain Benner & Contributors
;;
;; Author: Saul Alejandro Martinez Castelo <samacs@aries.local>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

;;; Commentary:

;; See the Spacemacs documentation and FAQs for instructions on how to implement
;; a new layer:
;;
;;   SPC h SPC layers RET
;;
;;
;; Briefly, each package to be installed or configured by this layer should be
;; added to `company-robe-packages'. Then, for each package PACKAGE:
;;
;; - If PACKAGE is not referenced by any other Spacemacs layer, define a
;;   function `company-robe/init-PACKAGE' to load and initialize the package.

;; - Otherwise, PACKAGE is already referenced by another Spacemacs layer, so
;;   define the functions `company-robe/pre-init-PACKAGE' and/or
;;   `company-robe/post-init-PACKAGE' to customize the package as it is loaded.

;;; Code:

(eval-when-compile (require 'robe))

;;;###autoload
(defun company-robe (command &optional arg &rest ignore)
  "A `company-mode` completion back-end for `robe-mode`."
  (interactive (list 'interactive))
  (case command
    (interactive (company-begin-with 'company-robe))
    (prefix (and (boundp 'robe-mode)
                 robe-mode (robe-running-p)
                 (company-robe--prefix)))
    (candidates (robe-complete-thing arg))
    (duplicates t)
    (meta (company-robe--meta arg))
    (location (let ((spec (company-robe--choose-spec arg)))
                (cons (robe-spec-file spec)
                      (robe-spec-line spec))))
    (annotation (robe-complete-annotation arg))
    (doc-buffer (let ((spec (company-robe--choose-spec arg)))
                  (when spec
                    (save-window-excursion
                      (robe-show-doc spec)
                      (message nil)
                      (get-buffer '*robe-doc*)))))))

(defun company-robe-meta (completion)
  (or
   (get-text-property 0 'robe-type completion)
   (let ((spec (car (robe-cached-specs completion))))
     (when spec (robe-signature spec)))))

(defun company-robe-prefix ()
  (let ((bounds (robe-complete-bounds)))
    (when (and bounds
               (equal (point) (cdr bounds))
               (robe-complete-symbol-p (car bounds)))
      (buffer-substring (car bounds) (cdr bounds)))))

(defun company-robe--choose-spec (thing)
  (let ((specs (robe-cached-specs thing)))
    (when specs
      (if (cdr specs)
          (let ((alist (cl-loop for spec in specs
                                for module = (robe-spec-module spec)
                                when module
                                collect (cons module spec))))
            (cdr (assoc (robe-completing-read "Modul: " alist nil t) alist)))
        (car specs)))))

(defconst company-robe-packages
  '()
  "The list of Lisp packages required by the company-robe layer.

Each entry is either:

1. A symbol, which is interpreted as a package to be installed, or

2. A list of the form (PACKAGE KEYS...), where PACKAGE is the
    name of the package to be installed or loaded, and KEYS are
    any number of keyword-value-pairs.

    The following keys are accepted:

    - :excluded (t or nil): Prevent the package from being loaded
      if value is non-nil

    - :location: Specify a custom installation location.
      The following values are legal:

      - The symbol `elpa' (default) means PACKAGE will be
        installed using the Emacs package manager.

      - The symbol `local' directs Spacemacs to load the file at
        `./local/PACKAGE/PACKAGE.el'

      - A list beginning with the symbol `recipe' is a melpa
        recipe.  See: https://github.com/milkypostman/melpa#recipe-format")

(provide 'company-robe)

;;; packages.el ends here
