;;; counsel-minor.el --- counsel to toggle minor mode  -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'ivy)

(defun counsel--minor-candidates ()
  "Return candidates of minor modes with lighter if available.

If DISABLED-MODES is non-nil, disabled minor modes are returned.
Otherwise, enabled minor modes are returned."
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

(defun counsel-minor (&optional initial-input)
  "Toggle minor-mode with completion.

INITIAL-INPUT is used as initial-input parameter of completion filter."
  (interactive)
  (ivy-read "Minor modes (enable +mode or disable -mode): "
            (counsel--minor-candidates)
            :require-match t
            :initial-input initial-input
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
