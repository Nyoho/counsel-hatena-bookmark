
(defun counsel-hatena-bookmark--candidates (str)
  (or
   (ivy-more-chars)
   (let* ((res (shell-command-to-string
                (format "w3m -dump 'https://b.hatena.ne.jp/my/search/json?q=%s'" (url-hexify-string str))))
          (json (json-parse-string res))
          (meta (gethash "meta" json))
          (bookmarks (gethash "bookmarks" json)))
     (message "str: %s | total: %d | res: s" str (gethash "total" meta) res)
     (if (eq (gethash "total" meta) 0)
         '("" "Not found.")
       (mapcar (lambda (item)
                 (let* ((ts (gethash "timestamp" item))
                        (date (format-time-string "%Y-%m-%d %a %H:%M:%S" (seconds-to-time ts)))
                        (comment (gethash "comment" item))
                        (entry (gethash "entry" item))
                        (url (gethash "url" entry))
                        (title (gethash "title" entry)))
                   (propertize (format "%s - %s\n%s\n%s" title url comment date) 'url url)))
               bookmarks)))))

;;;###autoload
(defun counsel-hatena-bookmark (&optional initial-input)
  "Search your Hatena Bookmark"
  (interactive)
  (counsel-require-program "w3m")
  (require 'url-util)
  (ivy-read "Bookmark: " #'counsel-hatena-bookmark--candidates
            ;; :history 'counsel-hatena-bookmark-history
            :dynamic-collection t
            :action (lambda (x)
                      (browse-url (get-text-property 0 'url x)))
            ;; (if counsel-hatena-bookmark-use-ivy-selector
            ;;     #'counsel-hatena-bookmark--select
            ;;   #'hatena-bookmark)
            :initial-input initial-input
            :require-match t
            :unwind #'counsel-delete-process
            :caller 'counsel-hatena-bookmark))


(defun counsel-hatena-bookmark--select (string)
  "Capture something with STRING as an initial input."
  (require 'w3m)
  (ivy-read (format "Capture template to pass \"%s\": " string)
            #'counsel-hatena-bookmark--template-list
            :require-match t
            :action (lambda (x)
                      (hatena-bookmark string (car (split-string x))))
            :caller 'counsel-hatena-bookmark--select))

(provide 'counsel-hatena-bookmark)
