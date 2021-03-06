;;; ob-emacs-lisp.el --- Babel Functions for Emacs-lisp Code -*- lexical-binding: t; -*-

;; Copyright (C) 2009-2016 Free Software Foundation, Inc.

;; Author: Eric Schulte
;; Keywords: literate programming, reproducible research
;; Homepage: http://orgmode.org

;; This file is part of GNU Emacs.

;; GNU Emacs is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Org-Babel support for evaluating emacs-lisp code

;;; Code:
(require 'ob)

(defvar org-babel-default-header-args:emacs-lisp nil
  "Default arguments for evaluating an emacs-lisp source block.")

(defun org-babel-expand-body:emacs-lisp (body params)
  "Expand BODY according to PARAMS, return the expanded body."
  (let* ((vars (org-babel--get-vars params))
         (result-params (cdr (assoc :result-params params)))
         (print-level nil) (print-length nil)
         (body (if (> (length vars) 0)
		   (concat "(let ("
			   (mapconcat
			    (lambda (var)
			      (format "%S" (print `(,(car var) ',(cdr var)))))
			    vars "\n      ")
			   ")\n" body "\n)")
		 (concat body "\n"))))
    (if (or (member "code" result-params)
	    (member "pp" result-params))
	(concat "(pp " body ")") body)))

(defun org-babel-execute:emacs-lisp (body params)
  "Execute a block of emacs-lisp code with Babel."
  (save-window-excursion
    (let ((result
           (eval (read (format (if (member "output"
                                           (cdr (assoc :result-params params)))
                                   "(with-output-to-string %s)"
                                 "(progn %s)")
                               (org-babel-expand-body:emacs-lisp
                                body params))))))
      (org-babel-result-cond (cdr (assoc :result-params params))
	(let ((print-level nil)
              (print-length nil))
          (if (or (member "scalar" (cdr (assoc :result-params params)))
                  (member "verbatim" (cdr (assoc :result-params params))))
              (format "%S" result)
            (format "%s" result)))
	(org-babel-reassemble-table
	 result
         (org-babel-pick-name (cdr (assoc :colname-names params))
                              (cdr (assoc :colnames params)))
         (org-babel-pick-name (cdr (assoc :rowname-names params))
                              (cdr (assoc :rownames params))))))))

(provide 'ob-emacs-lisp)



;;; ob-emacs-lisp.el ends here
