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
* Add some environment variables to your `~/.bashrc`, so your programs / scripts know where `java` is installed.
    The variables are:
    * JAVA_HOME: which points to the `~/.local/jdk/jdk-17.0.4.1`
    * PATH: which adds the `bin` directory located in the JAVA_HOME, so every executable is available for you to run

With this, you will have a *local* installation of java and even better, you can install multiple versions and then point
to the one you need.

This script only works (currently) for the jdk-17, since in order to download jdk-11 from oracle's page requires a login.

Usage
=====
```bash
git clone https://github.com/BlackCorsair/install-jdk-on-steam-deck.git
./install-jdk-on-steam-deck/scripts/install-jdk.sh
```

TO-DO
=====

* If you want anything added, just let me know by opening an [issue][3]

[1]: https://partner.steamgames.com/doc/steamdeck/faq
[2]: https://www.flatpak.org/
[3]: https://github.com/BlackCorsair/install-jdk-on-steam-deck/issues/new