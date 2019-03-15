;;; lift.el --- Move lines of text up and down  -*- lexical-binding: t; -*-

;; To the extent possible under law, the person who associated CC0 with this
;; work has waived all copyright and related or neighboring rights to this work.

;; Author: João Marques
;; Version: 0.1.0
;; Package-requires: ((emacs "26.1"))
;; Keywords: move, text, line
;; URL: https://github.com/mrshankly/lift.el

;;; Commentary:

;; A simple package that exposes two functions, `lift-lines-up' and
;; `lift-lines-down', which will move the current line or region up and down,
;; respectively.

;;; Code:

(defmacro lift-with-preserve-point (&rest body)
  `(let ((column (current-column)))
     ,@body
     (move-to-column column)))

(defun point-in-first-line-p ()
  (= (line-number-at-pos) (line-number-at-pos (point-min))))

(defun point-in-last-line-p ()
  (= (line-number-at-pos) (line-number-at-pos (1- (point-max)))))

;;;###autoload
(defun lift-lines-up ()
  "Move the current line or region up one line."
  (interactive)

  (if (use-region-p)
      ;; Region mode.
      nil

    ;; Single line mode.
    (unless (point-in-first-line-p)
      (lift-with-preserve-point
       (transpose-lines 1)
       (forward-line -2)))))

;;;###autoload
(defun lift-lines-down ()
  "Move the current line or region down one line."
  (interactive)

  (if (use-region-p)
      ;; Region mode.
      nil

    ;; Single line mode.
    (unless (point-in-last-line-p)
      (lift-with-preserve-point
       (forward-line 1)
       (transpose-lines 1)
       (forward-line -1)))))

(provide 'lift)

;;; lift.el ends here
