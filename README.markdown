# dot-files

**This is outdated** - my configuration has moved to https://github.com/hallettj/home.nix

This is the base configuration for my workstations.  It is managed with
[homeshick][], which creates symlinks from the appropriate locations in
my home directory.  Installing dependencies, compiling, and other setup
tasks are handled using [Ansible][], which runs the steps listed in
`init.yml`.

[homeshick]: https://github.com/andsens/homeshick
[Ansible]: http://www.ansibleworks.com/

I have other config file repositories that set up specific applications
or areas of functionality:

- [hallettj/dot-vim][]
- [hallettj/dot-xmonad][]
- [hallettj/dot-zsh][]

[hallettj/dot-vim]: https://github.com/hallettj/dot-vim
[hallettj/dot-xmonad]: https://github.com/hallettj/dot-xmonad
[hallettj/dot-zsh]: https://github.com/hallettj/dot-zsh

