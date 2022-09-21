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

So in order to install anything outside the software center (which installs programs in a way that doesn't affect
the OS by using [flatpak][2]), you have to modify things in you *home* directory, which shouldn't mess with the OS
and break the system.

Taking into account this, the script located in the `scripts` directory of this repository will:
* Download the official oracle JDK 17 compressed file into your **home** directory, more specifically into `~/.local/jdk`
* Check using the official checksum the file
* Extract the file into `~/.local/jdk/jdk-17.0.4.1`
* Add some environment variables to your `~/.bashrc` so your programs / scripts now where `java` is installed. The variables
    are:
    * JAVA_HOME
    * PATH

So you will have a *local* installation of java and even better, you can install multiple versions and then point to the
one you need.

This script only works (currently) for the jdk-17.

Usage
=====
```bash
git clone https://github.com/BlackCorsair/install-jdk-on-steam-deck.git
./install-jdk-on-steam-deck/scripts/install-jdk.sh
```

TO-DO
=====

* In the `install_jdk` function, replace all the `exit` commands for a cleanup function so the user
    can't have half-assed failed installation assets

[1]: https://partner.steamgames.com/doc/steamdeck/faq
[2]: https://www.flatpak.org/