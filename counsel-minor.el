;;; counsel-minor.el --- -*- lexical-binding: t -*-

(defvar counsel-minor-map
  (let ((map (make-sparse-keymap)))
    (define-key map "!" #'counsel-minor-toggle)
    map))

(defun counsel-minor-toggle ()
  "Toggle enabled and disabled minor modes for `counsel-minor'."
  (interactive)
  (ivy-exit-with-action
   (lambda (_x)
     (counsel-minor (eq (ivy-state-caller ivy-last) 'counsel-minor-enabled)
                    ivy-text))))

(defun counsel--minor-candidates (disabled-modes)
  "Return candidates of minor modes with lighter if available.

If DISABLED-MODES is non-nil, disabled minor modes are returned.
Otherwise, enabled minor modes are returned."
  (delq nil
        (mapcar
         (lambda (mode)
           (when (and (boundp mode)
                      (fboundp mode)
                      (if disabled-modes
                          (not (symbol-value mode))
                        (symbol-value mode)))
             (let ((lighter (alist-get mode minor-mode-alist)))
               (cons (concat
                      (symbol-name mode)
                      (propertize
                       (if lighter
                           (format " \"%s\""
                                   (format-mode-line (cons t lighter)))
                         "")
                       'face font-lock-string-face))
                     mode))))
                minor-mode-list)))

(defun counsel-minor (&optional disabled-modes initial-input)
  "Toggle minor-mode with completion.

If DISABLED-MODES is non-nil, disabled minor modes are displayed as candidate.
Otherwise, enabled minor modes are displayed.

INITIAL-INPUT is used as initial-input parameter of completion filter."
  (interactive)
  (let ((prompt (if disabled-modes
                    "Enable minor mode: "
                  "Disable minor mode: ")))
    (ivy-read prompt (counsel--minor-candidates disabled-modes)
              :require-match t
              :initial-input initial-input
              :keymap counsel-minor-map
              :sort t
              :action (lambda (x)
                        (call-interactively (cdr x)))
              :caller (if disabled-modes
                          'counsel-minor-disabled
                        'counsel-minor-enabled))))

(ivy-set-actions
 'counsel-minor-enabled
 `(("d" ,(lambda (x) (find-function (cdr x))) "definition")
   ("h" ,(lambda (x) (describe-function (cdr x))) "help")))
(ivy-set-actions
 'counsel-minor-disabled
 `(("d" ,(lambda (x) (find-function (cdr x))) "definition")
   ("h" ,(lambda (x) (describe-function (cdr x))) "help")))
