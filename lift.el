;;; lift.el --- Move lines of text up and down  -*- lexical-binding: t; -*-

;; To the extent possible under law, the person who associated CC0 with this
;; work has waived all copyright and related or neighboring rights to this work.

;; Author: João Marques
;; Version: 0.1.0
;; Package-requires: ((emacs "26.1"))
;; Keywords: move, text, line, convenience
;; URL: https://github.com/mrshankly/lift.el

;;; Commentary:

;; A simple package that exposes two functions, `lift-lines-up' and
;; `lift-lines-down', which will move the current line or region up and down,
;; respectively.

;;; Code:

(defun lift-point-in-first-line-p ()
  "Returns `t' if point is in the first line of the buffer."
  (= (line-number-at-pos) (line-number-at-pos (point-min))))

(defun lift-point-in-last-line-p ()
  "Returns `t' if point is in the last line of the buffer."
  (= (line-number-at-pos) (line-number-at-pos (1- (point-max)))))

(defun lift-count-region-lines ()
  "Returns the number of lines of the current region."
  (1+ (abs (- (line-number-at-pos)
              (line-number-at-pos (mark))))))

(defun lift-move-line (num-lines)
  "Moves the line where point is up or down by `num-lines' lines."
  (cond
   ((< num-lines 0) (progn
              ;; Move up just one line to handle the edge case when
              ;; there isn't a line after the current one.
              (transpose-lines 1)
              (forward-line -1)
              ;; Move more if there's anything more to move.
              (if (< (1+ num-lines) 0)
                  (transpose-lines (1+ num-lines)))
              (forward-line -1)))

   ((> num-lines 0) (progn
              ;; No edge case to handle when moving down.
              (forward-line 1)
              (transpose-lines num-lines)
              (forward-line -1)))))

(defun lift-move-region (direction)
  "Moves the current region up or down by one line."
  (let ((dont-move-p nil)
        (swap-point-and-mark nil)
        (num-lines (* direction (lift-count-region-lines))))

    (if (< direction 0)
        ;; Going up.
        (setq swap-point-and-mark (> (point) (mark))
              dont-move-p #'lift-point-in-first-line-p)
      ;; Going down.
      (setq swap-point-and-mark (< (point) (mark))
            dont-move-p #'lift-point-in-last-line-p))

    ;; Point should be in the first region line if we are going up,
    ;; or in the last region line if we are going down.
    (if swap-point-and-mark
        (exchange-point-and-mark))

    ;; Moving a region up or down by one line is the same as moving the line
    ;; immediately before or after the region up or down the number of lines
    ;; that region has.
    (unless (funcall dont-move-p)
        (let ((deactivate-mark nil)
              (column (current-column))
              (distance (- (mark) (point))))

          (forward-line direction)
          (lift-move-line (- num-lines))
          (forward-line num-lines)

          ;; Restore original region.
          (move-to-column column)
          (set-mark (+ (point) distance))))

    ;; Restore original point and mark if we swapped them before.
    (if swap-point-and-mark
        (exchange-point-and-mark))))

(defmacro lift-with-preserve-point (&rest body)
  `(let ((column (current-column)))
     ,@body
     (move-to-column column)))

;;;###autoload
(defun lift-lines-up ()
  "Moves the current line or region up one line."
  (interactive)
  (if (use-region-p)
      (lift-move-region -1)
    (unless (lift-point-in-first-line-p)
      (lift-with-preserve-point (lift-move-line -1)))))

;;;###autoload
(defun lift-lines-down ()
  "Moves the current line or region down one line."
  (interactive)
  (if (use-region-p)
      (lift-move-region +1)
    (unless (lift-point-in-last-line-p)
      (lift-with-preserve-point (lift-move-line 1)))))

(provide 'lift)
;;; lift.el ends here
