" Create new Asciio diagram in temporary folder
function! AsciioNewTemp()
	let line = getline('.')
	let tempn = tempname()
	let tempnt = tempn . '.txt'
	let temp = shellescape(tempn)
	let tempt = shellescape(tempnt)

	function! OnTerminalClose(a, b) closure
		exec "read " . tempnt
	endfunction

	exec "normal i asciio file:" . tempn . "\<Esc>"
	if ! has("gui_running")
		exec "silent !mkdir -p $(dirname " . temp . ")"
		exec "silent !cp ~/.config/Asciio/templates/empty.asciio ". temp

		let asciio_cmd = "/usr/bin/bash -c \"asciio " . tempn . " && asciio_to_text " . tempn . " > " . tempnt . "\""
		let id = term_start(asciio_cmd, { 'exit_cb': 'OnTerminalClose', 'hidden' : 1, 'norestore' : 1})
	endif
	redraw!
endfunction

" Edit existing Asciio diagram using full path (filename has to be selected; CTRL-V + :call GAsciioEdit())
function! AsciioEdit()
	let asciio_filename = getline("'<")[getpos("'<")[2]-1:getpos("'>")[2]-1]
	if filereadable(expand(asciio_filename))
		echo "Asciio filename: " . asciio_filename
		let asciio_text_fname = asciio_filename . '.txt'

		function! ReadTextOnTerminalClose(a, b) closure
			exec "read " . asciio_text_fname
		endfunction

		let asciio_cmd = "/usr/bin/bash -c \"asciio " . asciio_filename . " && asciio_to_text " . asciio_filename . " > " . asciio_text_fname . "\""
		let id = term_start(asciio_cmd, { 'exit_cb': 'ReadTextOnTerminalClose', 'hidden' : 1, 'norestore' : 1})

		redraw!
	endif
endfunction

function! GetAsciioDirName()
	let curr_dir_path = expand('%:p:h')
	let asciio_dir_path = curr_dir_path . '/.asc_objs'
	return asciio_dir_path
endfunction

function! AsciioDirInit()
	let asciio_dir_path = GetAsciioDirName()
	" echo "asciio storage: " . asciio_dir_path

	if isdirectory(asciio_dir_path)
		" echo "asciio storage exists"
	else
		call mkdir(asciio_dir_path, "p", 0755)
	endif
endfunction

" Create new Asciio diagram with the name provided by the user
" This new Asciio objects would be stored in .asc_objs directory of current
" working dir.
function! AsciioNew()
	" create asciio objects directory if needed
	call AsciioDirInit()

	call inputsave()
	let new_asc_name = input('asciio file name: ')
	call inputrestore()

	let asciio_dir_path = GetAsciioDirName()
	let asciio_file_path = asciio_dir_path . "/" . new_asc_name
	if filereadable(expand(asciio_file_path))
		echo "\nasciio file \'" . asciio_file_path . "\' already exists"
		return
	else
		echo "\nnew asciio file path: " . asciio_file_path
		exec "silent !cp ~/.config/Asciio/templates/empty.asciio " . asciio_file_path
		redraw!
	endif

	exec "normal i asciio file: " . new_asc_name . "\<Esc>"

	if filereadable(expand(asciio_file_path))
		echo "Asciio filename: " . asciio_file_path
		let asciio_text_fname = asciio_file_path . '.txt'

		function! ReadTextOnTerminalClose(a, b) closure
			exec "read " . asciio_text_fname
			exec "silent !rm " . asciio_text_fname
			redraw!
		endfunction

		let asciio_cmd = "/usr/bin/bash -c \"asciio " . asciio_file_path . " && asciio_to_text " . asciio_file_path . " > " . asciio_text_fname . "\""
		let id = term_start(asciio_cmd, { 'exit_cb': 'ReadTextOnTerminalClose', 'hidden' : 1, 'norestore' : 1})

		redraw!
	endif
endfunction

" Choose one of the existing asciio objects in current directory, edit it
" using GUI editor, render and read into the current buffer.
function! AsciioListEdit()
	silent let asc_files_list = split(system('ls -A ./.asc_objs'), '\n')

	func! AsciioMenuCb(id, result) closure
		echo "choice: " . a:id . " - " . a:result . " : " . asc_files_list[a:result - 1]

		let asciio_dir_path = GetAsciioDirName()
		let asciio_file_path = asciio_dir_path . "/" . asc_files_list[a:result - 1]
		if filereadable(expand(asciio_file_path))
			echo "Asciio filename: " . asciio_file_path
			let asciio_text_fname = asciio_file_path . '.txt'

			function! ReadTextOnTerminalClose(a, b) closure
				exec "read " . asciio_text_fname
				exec "silent !rm " . asciio_text_fname
				redraw!
			endfunction

			let asciio_cmd = "/usr/bin/bash -c \"asciio " . asciio_file_path . " && asciio_to_text " . asciio_file_path . " > " . asciio_text_fname . "\""
			let id = term_start(asciio_cmd, { 'exit_cb': 'ReadTextOnTerminalClose', 'hidden' : 1, 'norestore' : 1})

			redraw!
		endif
	endfunction

	if ! empty(asc_files_list)
		call popup_menu(asc_files_list, #{
			\ title: ' asciio files ',
			\ highlight: 'Question',
			\ border: [],
			\ cursorline: 1,
			\ pos: 'topleft',
			\ line: 'cursor+1',
			\ col: 'cursor+1',
			\ callback: 'AsciioMenuCb'})
	endif
endfunction

" Choose one of the exisiting asciio objects, render it and read into the current buffer
function! AsciioListRead()
	silent let asc_files_list = split(system('ls -A ./.asc_objs'), '\n')

	func! AsciioMenuCb(id, result) closure
		let asciio_dir_path = GetAsciioDirName()
		let asciio_file_path = asciio_dir_path . "/" . asc_files_list[a:result - 1]
		if filereadable(expand(asciio_file_path))
			echo "Asciio filename: " . asciio_file_path
			let asciio_text_fname = asciio_file_path . '.txt'

			function! ReadTextOnTerminalClose(a, b) closure
				exec "read " . asciio_text_fname
				exec "silent !rm " . asciio_text_fname
				redraw!
			endfunction

			let asciio_cmd = "/usr/bin/bash -c \"asciio_to_text " . asciio_file_path . " > " . asciio_text_fname . "\""
			let id = term_start(asciio_cmd, { 'exit_cb': 'ReadTextOnTerminalClose', 'hidden' : 1, 'norestore' : 1})

			redraw!
		endif
	endfunction

	if ! empty(asc_files_list)
		call popup_menu(asc_files_list, #{
			\ title: ' asciio files ',
			\ highlight: 'CursorLineFold',
			\ border: [],
			\ cursorline: 1,
			\ pos: 'topleft',
			\ line: 'cursor+1',
			\ col: 'cursor+1',
			\ callback: 'AsciioMenuCb'})
	endif
endfunction
