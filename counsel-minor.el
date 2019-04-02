;;; counsel-minor.el --- counsel to toggle minor mode  -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'ivy)

(defun counsel--minor-candidates ()
  "Return completion alist for `counsel-minor'.

The alist element is cons of minor mode string with its lighter
and minor mode symbol."
  (delq nil
        (mapcar
         (lambda (mode)
           (when (and (boundp mode) (commandp mode))
             (let ((lighter (alist-get mode minor-mode-alist)))
               (cons (concat
                      (if (symbol-value mode) "-" "+")
                      (symbol-name mode)
                      (propertize
                       (if lighter
                           (format " \"%s\""
                                   (format-mode-line (cons t lighter)))
                         "")
                       'face font-lock-string-face))
                     mode))))
                minor-mode-list)))

(defun counsel-minor ()
  "Enable or disable minor mode.

Disabled minor modes are prefixed with \"+\", and
selecting one of these will enable it.
Enabled minor modes are prefixed with \"-\", and
selecting one of these will enable it.

Additional actions:\\<ivy-minibuffer-map>

  \\[ivy-dispatching-done] d: Go to minor mode definition
  \\[ivy-dispatching-done] h: Describe minor mode"

  (interactive)
  (ivy-read "Minor modes (enable +mode or disable -mode): "
            (counsel--minor-candidates)
            :require-match t
            :sort t
            :action (lambda (x)
                      (call-interactively (cdr x)))))

(cl-pushnew '(counsel-minor . "^+ ") ivy-initial-inputs-alist :key #'car)

(ivy-set-actions
 'counsel-minor
 `(("d" ,(lambda (x) (find-function (cdr x))) "definition")
   ("h" ,(lambda (x) (describe-function (cdr x))) "help")))

(provide 'counsel-minor)
;;; counsel-minor.el ends here
