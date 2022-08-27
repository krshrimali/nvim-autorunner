# nvim-autorunner
# Author: Kushashwa Ravi Shrimali (kushashwaravishrimali@gmail.com)

if exists('g:loaded_autorunner')
  finish
endif

command! AutoRunnerRun lua require('autorunner').run()
command! AutoRunnerToggle lua require('autorunner').toggle()
command! AutoRunnerEditFile lua require('autorunner').edit_file()
command! AutoRunnerClearBuffer lua require('autorunner').clear_buffer()
command! AutoRunnerAddCommand lua require('autorunner').add_command()
command! AutoRunnerClearAll lua require('autorunner').clear_command_and_buffer()
command! AutoRunnerPrintCommand lua require('autorunner').print_command()

let g: loaded_autorunner = 1
