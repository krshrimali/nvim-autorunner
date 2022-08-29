# nvim-autorunner

A NeoVim lightweight autorunner plugin, to compile your projects using a single command.

I'm currently working on v0.1 (beta release), and the issue tracker is [here: v0.1 tracker](https://github.com/krshrimali/nvim-autorunner/issues/1). In case you have anything to add/remove/change, please post your opinion here. A few major TODOs:

* [ ] Add support for ToggleTerm - a much better terminal. (70% done), see: [file for all the available commands](https://github.com/krshrimali/nvim-autorunner/blob/main/plugin/autorunner.vim).
* [ ] Fix syncing buffers for stderr and stdout (when not using ToggleTerm)
* [ ] Documentation.
* [ ] Allowing users to customize options.

## Demo

See the animation below for a quick demo.

**Using ToggleTerm:** (beta release)

<img src="readme/ToggleTerm-AnimationDemo.gif"/>

**Using NeoVim Buffer:**

<img src="readme/AutoRunner.gif"/>

The plugin is also explained [here on my YouTube Channel](https://youtu.be/1tR_mrQXhJg).

## Setup/Installation

If you are using Packer, add:

```lua
use "krshrimali/nvim-autorunner"
-- depends on nvim-notify
use "rcarriga/nvim-notify"
```

Please use a similar pattern for other plugin managers. Currently, the plugin doesn't have a `setup` function, but I'm working on that. For now, just adding it to your package should enable the features.

**Adding to your shortcuts**: I like using `whichkey` for this, but feel free to have something else based on your needs. Checkout my whichkey shortcuts [here](https://github.com/krshrimali/nvim/blob/master/lua/user/whichkey.lua#L114).

```lua
a = {
  name = "AutoRunner",
  r = { "<cmd>AutoRunnerRun<cr>", "Run the command" },
  t = { "<cmd>AutoRunnerToggle<cr>", "Toggle output window" },
  e = { "<cmd>AutoRunnerEditFile<cr>", "Edit build file (if available in runtime directory)" },
  a = { "<cmd>AutoRunnerAddCommand<cr>", "Add/change command" },
  c = { "<cmd>AutoRunnerClearCommand<cr>", "Clear command" },
  C = { "<cmd>AutoRunnerClearAll<cr>", "Clear all (command and buffers)" },
  p = { "<cmd>AutoRunnerPrintCommand<cr>", "Print command" },
},
```

## Features

### `lua require("autorunner").run()`

- Runs a `.buildme.sh` (default command) or the added command (using `add_command` function) and shows a vertical split buffer with the output.
- If the file (check the file path using `print_command` function) doesn't exist, it will create the buffer with the output like "no such file or directory".
- If you already have a buffer opened through this plugin, make sure to close it before by calling `clear_buffer()` function.

### `lua require("autorunner").add_command()`

- Gives user a prompt to input the command they want to use. This will also be used in `edit_file()` in case you passed a shell script to work with.

### `lua require("autorunner").edit_file()`

- Ability to edit the file given through `add_command()` or the default: `.buildme.sh`.
- This will raise an error if the file is not found (through nvim-notify).

### `lua require("autorunner").clear_buffer()`

- In case, for some reason you don't see a window opening through `.toggle()` or `.run()` functions, try clearing the buffer.
- Pressing 'q' or 'Esc' keys in the normal mode will also call this method.

### `lua require("autorunner").clear_command_and_buffer()`

- In case you want to clear everything: buffers and command, call this method.

### `lua require("autorunner").print_command()()`

- Uses `nvim-notify` to print the current command to you.

### `lua require("autorunner").toggle()()`

- This shows you the output of the "last time you ran the command".
- If a window is already opened, this command will do nothing and show you an error with the buffer number. Please call the `.clear_buffer()` if you want to close that buffer (no need to pass the number).

## Acknowledgements

TJ's videos that helped me: 

1. [Automatically Execute *Anything* in Nvim](https://www.youtube.com/watch?v=9gUatBHuXE0)
2. [Execute **anything** in neovim (now customizable)](https://www.youtube.com/watch?v=HlfjpstqXwE)

Checkout TJ's [YouTube Channel](https://www.youtube.com/c/TJDeVries) and his [Twitch channel](https://www.twitch.tv/teej_dv). Sometimes I wish we had a senior like TJ in our college! Such a cool guy, down to Earth, and has a great impact in the community.

I want to give a shout out to Christian Chiarulli for his configs, his amazing and very friendly discord channel, and the whole community in the space, also for his very helpful streams and videos! Make sure to checkout his [GitHub](https://github.com/ChristianChiarulli) and [YouTube](https://www.youtube.com/channel/UCS97tchJDq17Qms3cux8wcA).

To ThePrimeagen, thank you so much for being the most positive person in the community, I saw you building your scripts, and it really "inspired" me to not give up learning. I'm still learning, but thank you for your content, streams, and hard work for everyone! Checkout his [YouTube channel](https://www.youtube.com/c/ThePrimeagen) and [Twitch](https://www.twitch.tv/ThePrimeagen).

Plugin: [nvim-buildme](https://github.com/ojroques/nvim-buildme/). I first started using it, and then thought to build my own. Feel free to check it out as well!

## Request to all

I understand that this might not be close to what everyone will expect, and that's why it's out here - I am looking for your feature requests, bug reports or issues, any questions - feel free to drop in the issues, and I'll make my best attempt to help.

This plugin is still in active development, and no-where close to a stable release, but I'm working in that direction. It should be useable though! :)
