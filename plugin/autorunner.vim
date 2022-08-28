" nvim-autorunner
" Author: Kushashwa Ravi Shrimali (kushashwaravishrimali@gmail.com)

command! AutoRunnerRun lua require('autorunner').run()
command! AutoRunnerToggle lua require('autorunner').toggle()
command! AutoRunnerEditFile lua require('autorunner').edit_file()
command! AutoRunnerClearBuffer lua require('autorunner').clear_buffer()
command! AutoRunnerAddCommand lua require('autorunner').add_command()
command! AutoRunnerClearAll lua require('autorunner').clear_command_and_buffer()
command! AutoRunnerPrintCommand lua require('autorunner').print_command()
command! AutoRunnerTermRun lua require('autorunner').term_run()
command! AutoRunnerTermToggle lua require('autorunner').term_toggle()
