(local api vim.api)

(var options {})

(fn output-file [filename]
  (filename:gsub ".[^]+$" ""))

(fn vim-commands []
  (vim.cmd "command! -bang -nargs=? Pandoc lua require'pandoc'.run_from_command(<q-args>, <q-bang>)"))

(fn setup [user_opts]
  (set options (vim.tbl_deep_extend "force" {} user_opts)))

; (= (type options) :table)

(fn render [opts]
  (if (= "table" (type opts)) (run)))

{: setup : render}
