# dot files
This project aims to be a multi-OS collection of templates of configuration files and Shell Script that help the users.

# Contents

* [Check IP](#check-ip)
	- [check_IP.service](#check_ipservice)
	- [check_IP.sh](#check_ipsh)
	- [check_IP.timer](#check_iptimer)
	- [install.sh](#installsh)
* [Desktop entries](#desktop-entries)
* [Makefile](#makefile)
* [Service Unit](#service-unit)
* [Shell Scripts](#shell-scripts)

# Check IP
The [check_IP](https://github.com/giulioc008/dot_files/tree/master/check_IP) project have the aims to retrieve every change of the IP of the default gateway of a Local Area Network (LAN); it is structured as
```
	/
	 check_IP.service
	 check_IP.sh
	 check_IP.timer
	 install.sh
```
## check_IP.service
This is the `systemd`'s Service Unit that run the Shell Script at boot time.

## check_IP.sh
This is the core of the project; this Shell Script check, through [ip6.me](http://ip6.me/), the IP of the default gateway of the LAN and print it or, through an FTP connection, post if on a site.

## check_IP.timer
This is the `systemd`'s Timer Unit that run the Shell Script every `10` minute from the first execution (boot time).

## install.sh
The installation file; it create the links for the correct function of the System Unit (Service and Timer).

# Desktop entries
The [desktop entries](https://github.com/giulioc008/dot_files/tree/master/desktop_entries) in this repository are intended to provide, where they may be missing (see KDE), the basic icons that an OS has.

# Makefile
The `makefile` into the repository is a template for a generic project in C with the following structure
```
	/
	 header/
	        lib.h
	 obj/
	     lib.o
	     main.o
	 source/
	        lib.c
	        main.c
```

# System Unit
The [`example.service`](https://github.com/giulioc008/dot_files/blob/master/lib/systemd/system/example.service) file is an example of a Service Unit used by `systemd`.

The file have a path that emulate the absolute path where it must be positioned; in add, it must be linked into `/etc/systemd/system` (`ln -s /lib/systemd/system/example.service /etc/systemd/system/example.service`).

# Shell Scripts
The Shell Scripts into this repository are a sort of libraries for the Shell, each with a specific purpose (`pacman.sh` -> better interface with `pacman`, etc.).
