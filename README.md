install-jdk-on-steam-deck
=========================

<!--ts-->
* [How it works](#how-it-works)
* [Usage](#usage)
* [TO-DO](#to-do)
<!--te-->

How it works
============
By default, the SteamDeck has a [read-only][1] immutable OS file system, which means that you can't simply
install anything using the `pacman` package manager that comes with the OS (arch linux), since it would modify
the OS file system.

So in order to install anything outside the Software Center (which installs programs in a way that doesn't affect
the OS by using [flatpak][2]), you have to modify things in you *home* directory, which shouldn't mess up with the OS
and break the system.

Taking this into account, the script located in the `scripts` directory of this repository will:
* Download the official oracle JDK 17 compressed file into your **home** directory, more specifically into `~/.local/jdk`
* Exec a checksum of the file using the official sha256 checksum
* Extract the file into `~/.local/jdk/jdk-17.0.4.1`
* Add some environment variables to your `~/.profile` and then source it, if it wasn't already sourced, in your bashrc,
  so your programs / scripts know where `java` is installed.
    The variables are:
    * JAVA_HOME: which points to the `~/.local/jdk/jdk-17.0.4.1`
    * PATH: which adds the `bin` directory located in the JAVA_HOME, so every executable is available for you to run

By adding the variables to `.profile` instead of `.bashrc` we ensure to be more "shell agnostic", so if you run
a script in another shell like `sh` or launch a graphical program, it should read the environment variables defined there.

`.profile` is "manually" sourced in `.bashrc` since `bash` will try to source first `.bash_profile` and `.bash_login` if they exist.
To learn about this:
* [man sh: Invocation][4]
* [bash manual: Invoked with name sh][5].

With this, you will have a *local* installation of java and even better, you can install multiple versions and then point
to the one you need.

This script only works (currently) for the jdk-17, since in order to download jdk-11 from oracle's page requires a login.

Usage
=====

You can choose which version to install by setting the variable `JDK_VERSION` before executing the script, you can
even do it on the same command! If you don't select any version, `jdk-21` will be installed by default.

To install **jdk-17** (openjdk):
```bash
git clone https://github.com/BlackCorsair/install-jdk-on-steam-deck.git && \
JDK_VERSION=17 ./install-jdk-on-steam-deck/scripts/install-jdk.sh
```

To install **jdk-21**:
```bash
git clone https://github.com/BlackCorsair/install-jdk-on-steam-deck.git && \
JDK_VERSION=21 ./install-jdk-on-steam-deck/scripts/install-jdk.sh
```

NOTE: jdk-17 is no longer obtainable from oracle, so the openjdk version from (https://jdk.java.net/archive/) will
be used instead. This will also happen in the future to jdk-21, probably once jdk-23 is fully embraced.

How to uninstall it
===================

```bash
# remove the installation directory this script creates
rm -rf /home/deck/.local/jdk

# remove the ~/.profile file this script creates OR remove the lines using an editor:
# export JAVA_HOME=/home/deck/.local/jdk
# export PATH=$PATH:/home/deck/.local/jdk/jdk-17.0.8/bin
rm -f ~/.profile

# Optionally, you can remove the line added to your bashrc
#
# [[ -f ~/.profile ]] && source ~/.profile
#
# This line shouldn't interfere with anything since it doesn't load the ~/.profile unless it exists
```

TO-DO
=====

* Add an uninstall script or option
* Add support for java 8 (see [issue](https://github.com/BlackCorsair/install-jdk-on-steam-deck/issues/3))
* If you want anything added, just let me know by opening an [issue][3]

[1]: https://partner.steamgames.com/doc/steamdeck/faq
[2]: https://www.flatpak.org/
[3]: https://github.com/BlackCorsair/install-jdk-on-steam-deck/issues/new
[4]: https://man.freebsd.org/cgi/man.cgi?query=sh&manpath=Unix+Seventh+Edition
[5]: https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html#Bash-Startup-Files
