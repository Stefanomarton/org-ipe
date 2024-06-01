(require 'f)
(require 'org)

(defcustom org-ipe-folder "ipe-figure"
  "ipe figures folder"
  :group 'org-ipe
  :type 'string)

(defcustom org-ipe-image-width 7
  "ipe figures folder"
  :group 'org-ipe
  :type 'integer
  )

(defun org-ipe-open (path &optional _)
  "Open the PATH in IPE"
  (interactive)
  ;; Remove the .svg extension
  (let ((display-buffer-alist '(("*Async Shell Command*" . (display-buffer-no-window . ()))))
        (path (file-name-sans-extension path)))
    ;; Run the IPE command
    (async-shell-command (format "ipe %s.ipe && iperender -svg %s.ipe %s.svg" path path path) nil nil)))

(defun org-ipe-insert-drawing (path)
  "Convenience function to insert a drawing with filename PATH."
  (interactive "sFilename: ")
  (unless (file-exists-p path)
    (mkdir org-ipe-folder t))
  (shell-command (concat "touch " (file-name-directory buffer-file-name) org-ipe-folder (format "/%s.svg" path)))
  (insert (concat "#+attr_latex: :width "(format "%scm\n" org-ipe-image-width)
                  "file:" (file-name-directory buffer-file-name) org-ipe-folder (format "/%s.svg" path))))

(add-to-list 'org-file-apps '("\\.svg\\'" . org-ipe-open))

(provide 'org-ipe)
