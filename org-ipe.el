(require 'f)
(require 'org)

(defcustom org-ipe-folder nil
  "Directory for IPE figures."
  :group 'org-ipe
  :type 'string)

(defcustom org-ipe-image-width 7
  "Width of IPE figures in cm for LaTeX export."
  :group 'org-ipe
  :type 'integer)

(defcustom org-ipe-open-after-insert t
  "Whether to open the new IPE file immediately after inserting it."
  :type 'boolean
  :group 'org-ipe)

(defun org-ipe-open (path &optional _)
  "Open the PATH in IPE and regenerate SVG silently."
  (interactive)
  (let* ((base (file-name-sans-extension path))
         (ipe-file (concat base ".ipe"))
         (svg-file (concat base ".svg"))
         (cmd (format "ipe %s && iperender -svg %s %s"
                      (shell-quote-argument ipe-file)
                      (shell-quote-argument ipe-file)
                      (shell-quote-argument svg-file))))
    ;; Run without displaying a buffer
    (start-process-shell-command
     "org-ipe-process" nil cmd)))

(defun org-ipe--generate-timestamp-filename ()
  "Generate a timestamp string like %Y%m%dT%H%M%S."
  (format-time-string "%Y%m%dT%H%M%S_ipe"))

(defun org-ipe-insert-drawing ()
  "Insert a drawing reference with a timestamped filename, creating the folder if necessary."
  (interactive)
  (let* ((name (org-ipe--generate-timestamp-filename))
         (dir (expand-file-name org-ipe-folder (file-name-directory buffer-file-name)))
         (svg-path (concat dir "/" name ".svg"))
         (relative-path (concat org-ipe-folder "/" name ".svg")))
    ;; Create folder if it doesn't exist
    (unless (file-directory-p dir)
      (make-directory dir t))
    ;; Create the empty SVG file
    (f-touch svg-path)
    ;; Insert Org link
    (insert (format "#+attr_latex: :width %scm\nfile:%s\n"
                    org-ipe-image-width
                    relative-path))
    (when org-ipe-open-after-insert
      (org-ipe-open svg-path))))

;; Only open SVGs ending in ipe.svg with org-ipe
(add-to-list 'org-file-apps '("\\ipe\\.svg\\'" . org-ipe-open))

(provide 'org-ipe)
