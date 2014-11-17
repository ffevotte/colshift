# colshift

`colshift` allows reorganizing Emacs split windows by moving columns around.

## Examples

In the illustrations below, the big rectangle represents an emacs frame, split into windows respectively showing buffers `A`, `B`, `C` and `D`. `B` and `C` are grouped into a column, and will be moved together. In the examples, it is assumed that `C` is the currently selected window.

- `M-x colshift/rotate-forward` performs a circular permutation of all columns:

        +-------+-------+-------+                             +-------+-------+-------+
        |       |       |       |                             |       |       |       |
        |       |   B   |       |                             |       |       |   B   |
        |       +-------+       |   colshift/rotate-forward   |       |       +-------+
        |   A   |       |   D   | --------------------------> |   D   |   A   |       |
        |       |  (C)  |       |                             |       |       |  (C)  |
        |       |       |       |                             |       |       |       |
        |       |       |       |                             |       |       |       |
        +-------+-------+-------+                             +-------+-------+-------+


- `M-x colshift/shift-right` shifts the currently selected column to the right:

        +-------+-------+-------+                            +-------+-------+-------+
        |       |       |       |                            |       |       |       |
        |       |   B   |       |                            |       |       |   B   |
        |       +-------+       |    colshift/shift-right    |       |       +-------+
        |   A   |       |   D   | -------------------------> |   A   |   D   |       |
        |       |  (C)  |       |                            |       |       |  (C)  |
        |       |       |       |                            |       |       |       |
        |       |       |       |                            |       |       |       |
        +-------+-------+-------+                            +-------+-------+-------+


## Installation

### Manual installation

From `git`:

1. get the repository:

   ```sh
   $ git clone https://github.com/ffevotte/colshift.git
   ```

2. add the following snippet to your init file:

   ```lisp
   (add-to-list 'load-path "/path/to/colshift")
   (require 'colshift)
   ```

## Setup

Bind the `colshift/*` commands to keys of your liking. For example:

```lisp
(global-set-key (kbd "H-<right>") #'colshift/shift-right)
(global-set-key (kbd "H-<left>")  #'colshift/shift-left)
(global-set-key (kbd "H-<down>")  #'colshift/rotate-forward)
(global-set-key (kbd "H-<up>")    #'colshift/rotate-backward)
```

## User interface

`colshift` defines 4 user-level commands:

- `colshift/shift-right`: shifts the currently selected column (windows `B`+`C` in the illustration above) right. The column is swapped with its right neighbour. The topology is not cyclic (i.e. nothing happens if the column is already in the rightmost position in the frame).

- `colshift/shift-left`: shifts the currently selected column left, with a behavious very similar to `colshift/shift-right`.

- `colshift/rotate-forward`: performs a circular permutation of all columns. Each columns takes the place of its right neighbour; the last column goes to the first position.

- `colshift/rotate-backward`: same behaviour as `colshift/rotate-forward`, except that each column takes the place of its left neighbour.
