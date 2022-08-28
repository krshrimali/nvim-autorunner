This is a tracker for v0.1 release - which will be a beta release for all users. Currently, the plugin is in alpha release, and in active development. Please report issues if you find any.

  * [ ] Add `setup()` function, with options for the buffer window and more.
    * [ ] Add options to allow choosing between horizontal split / vertical split.
    * [ ] Add options for width and height.
    * [ ] Add option for number and relativenumber.
  * [ ] Separate "command" and "build file".
  * [ ] `edit_file()` function should edit the `build file` and not the `command`.
  * [ ] (probably) add an `initialize_project()` function which creates an empty (a message might be good here) `.autorun.sh` file for the user.
  * [ ] Add testing.
  * [ ] Add Wiki and more documentation
  * [ ] Bug Fixes:
    * [ ] Autoscroll buffer (give users an option to disable it).
    * [ ] Don't set the buffer modifiable.
    * [ ] Don't set keymaps within the plugin. Or maybe give them an option to either let the plugin handle it.
    * [ ] Raise a warning if the buffer is not closed, but is left.
