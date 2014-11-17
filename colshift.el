;;; colshift.el --- Reorder columns (or rows) of windows in a frame

;; Copyright 2014 François Févotte

;; Author: François Févotte <fevotte@gmail.com>
;; URL: http://github.com/ffevotte/colshift
;; Version: 0.1
;; Package-Requires: ((dash "2.9.0"))

;;; Commentary:
;;

(require 'dash)

;;; Code:

(defun colshift--get-column-window (col)
  "Get the window object identifying column COL.
COL should be a column data type as retrieved within the state
returned by `window-state-get'."
  (cdr (assq 'clone-of
             (cdr (assq 'parameters
                        col)))))

(defun colshift--selected-column-window ()
  "Get the window object identifying the currently selected column."
  (let ((root   (frame-root-window))
        (parent (selected-window))
        window)
    (while (not (eq parent root))
      (setq window parent)
      (setq parent (window-parent window)))
    (colshift--get-column-window
     (cddr (window-state-get window)))))

(defun colshift--rotate (columns count)
  "Rotate the given COLUMNS COUNT times.
Rotate columns forward if COUNT is positive, backwards
otherwise.
COLUMNS should be a list of column data structures, as retrieved
within the state returned by `window-state-get'."
  (let* ((size   (length columns))
         (index  (mod (- size count) size))
         (split  (-split-at index columns))
         (part1  (car  split))
         (part2  (cadr split)))
    (-concat part2 part1)))

(defun colshift--shift (columns count)
  "Shift the currently selected column COUNT times.
Columns are shifted right if COUNT is positive, left otherwise.
COLUMNS should be a list of column data structures, as retrieved
with the state returned by `window-state-get'."
  (let* ((size (length columns))
         (increment (if (> count 0) 1 -1))
         (count (if (> count 0) count (- count)))
         (selected-column-window (colshift--selected-column-window))
         (index1 (-find-index (lambda (col)
                                (eq selected-column-window
                                    (colshift--get-column-window col)))
                              columns))
         index2)
    (dotimes (i count)
      (setq index2 (max 0 (+ index1 increment)))
      (when (and (>= index2 0)
                 (< index2 size))
        (rotatef (nth index1 columns)
                 (nth index2 columns)))
      (setq index1 index2))
    columns))

(defun colshift--reorder (fn count)
  "Perform a columns reordering in the currently selected frame.
Reordering is performed by the given function FN, which should
take as arguments a list of columns and the number of times the
reordering should be performed.
COUNT is the number of times the reordering should be performed."
  (let ((win-state (window-state-get (frame-root-window))))
    (let ((split-state (cddr win-state))
          header columns)

      ;; Isolate the list of columns from the window parameters
      (mapc (lambda (param)
              (if (memq (car param) '(hc vc leaf))
                  ;; Column: remove the (last . t) parameter if present
                  (push (cons (car param)
                              (assq-delete-all 'last (cdr param)))
                        columns)
                ;; Header
                (push param header)))
            split-state)

      ;; Reorder columns
      (setq columns (funcall fn (nreverse columns) count))

      ;; Add the (last . t) parameter to the last column
      (let ((last (-last-item columns)))
        (setcdr last (cons '(last . t)
                           (cdr last))))

      ;; Update the window state data structure...
      (setf (cddr win-state)
            (concatenate 'list
                         (nreverse header)
                         columns)))
    ;; ...and actually install it in the root window
    (delete-other-windows)
    (window-state-put win-state nil 'safe)))

;;;###autoload
(defun colshift/shift-right (count)
  "Shift the currently selected column COUNT times.
Columns are shifted right if COUNT is positive, left otherwise."
  (interactive "p")
  (colshift--reorder #'colshift--shift count))

;;;###autoload
(defun colshift/shift-left (count)
    "Shift the currently selected column COUNT times.
Columns are shifted left if COUNT is positive, right otherwise."
  (interactive "p")
  (colshift--reorder #'colshift--shift (- count)))

;;;###autoload
(defun colshift/rotate-forward (count)
  "Rotate the columns COUNT times.
Rotate columns forward if COUNT is positive, backwards
otherwise."
  (interactive "p")
  (colshift--reorder #'colshift--rotate count))

;;;###autoload
(defun colshift/rotate-backward (count)
  "Rotate the columns COUNT times.
Rotate columns backward if COUNT is positive, forward
otherwise."
  (interactive "p")
  (colshift--reorder #'colshift--rotate (- count)))

(provide 'colshift)

;;; colshift.el ends here
