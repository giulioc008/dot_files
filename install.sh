#!/bin/sh

#####################################################################################################################
#	Filename:		~/Documents/GitHub/dot_files/install.sh															#
#	Purpose:		file that append the include of the opportune Shell Script into the Shell's configuration file	#
#					and create the links for the opportune scripts into the opportune paths							#
#	Authors:		Giulio Coa <34110430+giulioc008@users.noreply.github.com>										#
#	License:		This file is licensed under the LGPLv3.															#
#####################################################################################################################

## Colors
red_bold='\[\e[1;31m\]'
red_background='\[\e[41m\]'
white='\[\e[0;37m\]'

reset='\[\e[0m\]'																# reset the color to the default value

# Cache the output of uname so we don't have to spawn it multiple times.
function cache_uname {
	IFS=' ' read -ra uname <<< "$(uname -srm)"

	kernel_name="${uname[0]}"
	kernel_version="${uname[1]}"
	kernel_machine="${uname[2]}"

	if [ "$kernel_name" == 'Darwin' ]
	then
		IFS=$'\n' read -d '' -ra sw_vers <<< "$(awk -F'<|>' '/key|string/ {print $3}' '/System/Library/CoreServices/SystemVersion.plist')"

		for ((i = 0; i < ${#sw_vers[@]}; i += 2)) {
			case ${sw_vers[i]} in
				ProductName)
					darwin_name=${sw_vers[i+1]}
					break
					;;
				ProductVersion)
					osx_version=${sw_vers[i+1]}
					break
					;;
				ProductBuildVersion)
					osx_build=${sw_vers[i+1]}
 					break
					;;
		   esac
		}
	fi
}

function get_de {
	[ $de ] && return

	case $os in
		Mac OS X | macOS)
			de=Aqua
			break
			;;
		Windows)
			case $distro in
				*Windows 10*)
					de=Fluent
					break
					;;
				*Windows 8*)
					de=Metro
					break
					;;
				*)
					de=Aero
					break
					;;
			esac

			break
			;;
		FreeMiNT)
			freemint_wm=(/proc/*)

			case ${freemint_wm[*]} in
				*thing*)
					de=Thing
					break
					;;
				*jinnee*)
					de=Jinnee
					break
					;;
				*tera*)
					de=Teradesk
					break
					;;
				*neod*)
					de=NeoDesk
					break
					;;
				*zdesk*)
					de=zDesk
					break
					;;
				*mdesk*)
					de=mDesk
					break
					;;
			esac

			break
			;;
		*)
			# Temporary support for Regolith Linux
			if [ $DESKTOP_SESSION == regolith ]
			then
				de=Regolith
			elif [ $XDG_CURRENT_DESKTOP ]
			then
				de=${XDG_CURRENT_DESKTOP/X\-}
				de=${de/Budgie:GNOME/Budgie}
				de=${de/:Unity7:ubuntu}
			elif [ $DESKTOP_SESSION ]
			then
				de=${DESKTOP_SESSION##*/}
			elif [ $GNOME_DESKTOP_SESSION_ID ]
			then
				de=GNOME
			elif [ $MATE_DESKTOP_SESSION_ID ]
			then
				de=MATE
			elif [ $TDE_FULL_SESSION ]
			then
				de=Trinity
			fi

			break
			;;
	esac

	# Fallback to using xprop.
	[ $DISPLAY ] && [ -z $de ] && type -p xprop &> /dev/null && de=$(xprop -root | awk '/KDE_SESSION_VERSION | ^_MUFFIN | xfce4 | xfce5/')

	# Format strings.
	case $de in
		KDE_SESSION_VERSION*)
			de=KDE${de/* = }
			break
			;;
 		*xfce4*)
			de=Xfce4
			break
			;;
		*xfce5*)
			de=Xfce5
			break
			;;
		*xfce*)
			de=Xfce
			break
			;;
		*mate*)
			de=MATE
			break
			;;
		*GNOME*)
			de=GNOME
			break
			;;
		*MUFFIN*)
			de=Cinnamon
			break
			;;
	esac

	((${KDE_SESSION_VERSION:-0} >= 4)) && de=${de/KDE/Plasma}

	if [ $de_version == on ] && [ $de ]
	then
		case $de in
			Plasma*)
				de_ver=$(plasmashell --version)
				break
				;;
			MATE*)
				de_ver=$(mate-session --version)
				break
				;;
			Xfce*)
				de_ver=$(xfce4-session --version)
				break
				;;
			GNOME*)
				de_ver=$(gnome-shell --version)
				break
				;;
			Cinnamon*)
				de_ver=$(cinnamon --version)
				break
				;;
			Deepin*)
				de_ver=$(awk -F'=' '/Version/ {print $2}' /etc/deepin-version)
				break
				;;
			Budgie*)
				de_ver=$(budgie-desktop --version)
				break
				;;
			LXQt*)
				de_ver=$(lxqt-session --version)
				break
				;;
			Lumina*)
				de_ver=$(lumina-desktop --version 2>&1)
				break
				;;
			Trinity*)
				de_ver=$(tde-config --version)
				break
				;;
			Unity*)
				de_ver=$(unity --version)
				break
				;;
		esac

		de_ver=${de_ver/*TDE:}
		de_ver=${de_ver/tde-config*}
		de_ver=${de_ver/liblxqt*}
		de_ver=${de_ver/Copyright*}
		de_ver=${de_ver/)*}
		de_ver=${de_ver/* }
		de_ver=${de_ver//\"}

		de+=" $de_ver"
	fi

	[ $de ] && [ $WAYLAND_DISPLAY ] && de+=' (Wayland)'
}

function get_distro {
	[ $distro ] && return

	case $os in
		Linux | BSD | MINIX)
			if [ -f /bedrock/etc/bedrock-release ] && [ $PATH == */bedrock/cross/* ]
			then
				distro=$(< /bedrock/etc/bedrock-release)
			elif [ -f /etc/redstar-release ]
			then
				distro="Red Star OS $(awk -F'[^0-9*]' '$0=$2' /etc/redstar-release)"
			elif [ -f /etc/armbian-release ]
			then
				. /etc/armbian-release
				distro="Armbian ${DISTRIBUTION_CODENAME} (${VERSION:-})"
			elif [ -f /etc/siduction-version ]
			then
				distro="Siduction ($(lsb_release -sic))"
			elif [ -f /etc/mcst_version ]
			then
				distro="OS Elbrus $(< /etc/mcst_version)"
			elif type -p pveversion >/dev/null
			then
				distro=$(pveversion)
				distro=${distro#pve-manager/}
				distro="Proxmox VE ${distro%/*}"
			elif type -p lsb_release >/dev/null
			then
				distro=$(lsb_release -sd)
			elif [ -f /etc/os-release ] || [ -f /usr/lib/os-release ] || [ -f /etc/openwrt_release ] || [ -f /etc/lsb-release ]
			then
				# Source the os-release file
				for file in /etc/lsb-release /usr/lib/os-release /etc/os-release /etc/openwrt_release
				do
					source "$file" && break
				done

				# Format the distro name
				distro="${PRETTY_NAME:-${DISTRIB_DESCRIPTION}} ${UBUNTU_CODENAME}"
			elif [ -f /etc/GoboLinuxVersion ]
			then
				distro="GoboLinux $(< /etc/GoboLinuxVersion)"
			elif [ -f /etc/SDE-VERSION ]
			then
				distro="$(< /etc/SDE-VERSION)"
			elif type -p crux >/dev/null
			then
				distro=$(crux)
			elif type -p tazpkg >/dev/null
			then
				distro="SliTaz $(< /etc/slitaz-release)"
			elif type -p kpt >/dev/null && type -p kpm >/dev/null
			then
				distro=KSLinux
			elif [ -d /system/app/ ] && [ -d /system/priv-app ]
			then
				distro="Android $(getprop ro.build.version.release)"
			# Chrome OS doesn't conform to the /etc/*-release standard
			# While the file is a series of variables they can't be sourced by the shell since the values aren't quoted
			elif [ -f /etc/lsb-release ] && [ $(< /etc/lsb-release) == *CHROMEOS* ]
			then
				distro='Chrome OS'
			elif type -p guix >/dev/null
			then
				distro="Guix System $(guix -V | awk 'NR==1{printf $4}')"
			# Display whether using '-current' or '-release' on OpenBSD
			elif [ $kernel_name = OpenBSD ]
			then
				read -ra kernel_info <<< "$(sysctl -n kern.version)"
				distro=${kernel_info[*]:0:2}
			else
				for release_file in /etc/*-release
				do
					distro+=$(< "$release_file")
				done

				if [ -z $distro ]
				then
					distro="$kernel_name $kernel_version"
					distro=${distro/DragonFly/DragonFlyBSD}

					# Workarounds for some BSD based distros
					[ -f /etc/pcbsd-lang ] && distro=PCBSD
					[ -f /etc/trueos-lang ] && distro=TrueOS
					[ -f /etc/pacbsd-release ] && distro=PacBSD
					[ -f /etc/hbsd-update.conf ] && distro=HardenedBSD
				fi
			fi

			if [ $(< /proc/version) == *'Microsoft'* ] || [ $kernel_version == *'Microsoft'* ]
			then
				distro+=' on Windows 10'
			elif [ $(< /proc/version) == *'chrome-bot'* ] || [ -f /dev/cros_ec ]
			then
				[ $distro != *'Chrome'* ] && distro+=' on Chrome OS'
			fi

			distro=$(trim_quotes "$distro")
			distro=${distro/NAME=}

			# Get Ubuntu flavor.
			if [ $distro == 'Ubuntu'* ]
			then
				case $XDG_CONFIG_DIRS in
					*plasma*)
						distro=${distro/Ubuntu/Kubuntu}
						break
						;;
					*mate*)
						distro=${distro/Ubuntu/Ubuntu MATE}
						break
						;;
					*xubuntu*)
						distro=${distro/Ubuntu/Xubuntu}
						break
						;;
					*Lubuntu*)
						distro=${distro/Ubuntu/Lubuntu}
						break
						;;
					*budgie*)
						distro=${distro/Ubuntu/Ubuntu Budgie}
						break
						;;
					*studio*)
						distro=${distro/Ubuntu/Ubuntu Studio}
						break
						;;
					*cinnamon*)
						distro=${distro/Ubuntu/Ubuntu Cinnamon}
						break
						;;
				esac
			fi
			break
			;;
		Mac OS X | macOS)
			case $osx_version in
				10.4*)
					codename='Mac OS X Tiger'
					break
					;;
				10.5*)
					codename='Mac OS X Leopard'
					break
					;;
				10.6*)
					codename='Mac OS X Snow Leopard'
					break
					;;
				10.7*)
					codename='Mac OS X Lion'
					break
					;;
				10.8*)
					codename='OS X Mountain Lion'
					break
					;;
				10.9*)
					codename='OS X Mavericks'
					break
					;;
				10.10*)
					codename='OS X Yosemite'
					break
					;;
				10.11*)
					codename='OS X El Capitan'
					break
					;;
				10.12*)
					codename='macOS Sierra'
					break
					;;
				10.13*)
					codename='macOS High Sierra'
					break
					;;
				10.14*)
					codename='macOS Mojave'
					break
					;;
				10.15*)
					codename='macOS Catalina'
					break
					;;
				10.16*)
					codename='macOS Big Sur'
					break
					;;
				11.0*)
					codename='macOS Big Sur'
					break
					;;
				*)
					codename='macOS'
					break
					;;
			esac

			distro="$codename $osx_version $osx_build"
			break
			;;
		iPhone OS)
			distro="iOS $osx_version"

			break
			;;
		Windows)
			distro=$(wmic os get Caption)
			distro=${distro/Caption}
			distro=${distro/Microsoft }

			break
			;;
		Solaris)
			distro=$(awk 'NR==1 {print $1,$2,$3}' /etc/release)
			distro=${distro/\(*}
			break
			;;
		Haiku)
			distro='Haiku'
			break
			;;
		AIX)
			distro="AIX $(oslevel)"
			break
			;;
		IRIX)
			distro="IRIX ${kernel_version}"
			break
			;;
		FreeMiNT)
			distro='FreeMiNT'
			break
			;;
	esac

	distro=${distro//Enterprise Server}
	[ $distro ] || distro="$os (Unknown)"

	# Get OS architecture.
	case $os in
		Solaris | AIX | Haiku | IRIX | FreeMiNT)
			machine_arch=$(uname -p)
			break
			;;
		*)
			machine_arch=$kernel_machine
			break
			;;
	esac

	[ $os_arch == on ] && distro+=" $machine_arch"
	[ ${ascii_distro:-auto} == auto ] && ascii_distro=$(trim "$distro")
}

function get_kernel {
	# Since these OS are integrated systems, it's better to skip this function altogether
	[[ $os =~ ('AIX' | 'IRIX') ]] && return

	# Haiku uses 'uname -v' and not - 'uname -r'.
	[ $os == 'Haiku' ] && {
		kernel=$(uname -v)
		return
	}

	# In Windows 'uname' may return the info of GNUenv thus use wmic for OS kernel.
	[ $os == 'Windows' ] && {
		kernel=$(wmic os get Version)
		kernel=${kernel/Version}
		return
	}

	kernel="$kernel_name $kernel_version"

	# Hide kernel info if it's identical to the distro info.
	[[ $os =~ ('BSD' | 'MINIX') ]] && [ $distro == *"$kernel_name"* ] && unset kernel
}

function get_model {
	case $os in
		Linux)
			if [ -d /system/app/ ] && [ -d /system/priv-app ]
			then
				model="$(getprop ro.product.brand) $(getprop ro.product.model)"
			elif [ -f /sys/devices/virtual/dmi/id/product_name ] || [ -f /sys/devices/virtual/dmi/id/product_version ]
			then
				model=$(< /sys/devices/virtual/dmi/id/product_name)
				model+=" $(< /sys/devices/virtual/dmi/id/product_version)"
			elif [ -f /sys/firmware/devicetree/base/model ]
			then
				model=$(< /sys/firmware/devicetree/base/model)
			elif [ -f /tmp/sysinfo/model ]
			then
				model=$(< /tmp/sysinfo/model)
			fi

			break
			;;
		Mac OS X | macOS)
			if [ $(kextstat | grep -F -e 'FakeSMC' -e 'VirtualSMC') != '' ]
			then
				model="Hackintosh (SMBIOS: $(sysctl -n hw.model))"
			else
				model=$(sysctl -n hw.model)
			fi

			break
			;;
		iPhone OS)
			case $kernel_machine in
				iPad1,1):
					'iPad'
					break
					;;
				iPad2,[1-4])
					'iPad 2'
					break
					;;
				iPad3,[1-3])
					'iPad 3'
					break
					;;
				iPad3,[4-6])
					'iPad 4'
					break
					;;
				iPad6,1[12])
					'iPad 5'
					break
					;;
				iPad7,[5-6])
					'iPad 6'
					break
					;;
				iPad7,1[12])
					'iPad 7'
					break
					;;
				iPad4,[1-3])
					'iPad Air'
					break
					;;
				iPad5,[3-4])
					'iPad Air 2'
					break
					;;
				iPad11,[3-4]):
					'iPad Air 3'
					break
					;;
				iPad6,[7-8])
					'iPad Pro (12.9 Inch)'
					break
					;;
				iPad6,[3-4])
					'iPad Pro (9.7 Inch)'
					break
					;;
				iPad7,[1-2])
					'iPad Pro 2 (12.9 Inch)'
					break
					;;
				iPad7,[3-4])
					'iPad Pro (10.5 Inch)'
					break
					;;
				iPad8,[1-4])
					'iPad Pro (11 Inch)'
					break
					;;
				iPad8,[5-8])
					'iPad Pro 3 (12.9 Inch)'
					break
					;;
				iPad8,9 | iPad8,10):
					'iPad Pro 4 (11 Inch)'
					break
					;;
				iPad8,1[1-2]):
					'iPad Pro 4 (12.9 Inch)'
					break
					;;
				iPad2,[5-7])
					'iPad mini'
					break
					;;
				iPad4,[4-6])
					'iPad mini 2'
					break
					;;
				iPad4,[7-9])
					'iPad mini 3'
					break
					;;
				iPad5,[1-2])
					'iPad mini 4'
					break
					;;
				iPad11,[1-2]):
					'iPad mini 5'
					break
					;;
				iPhone1,1):
					'iPhone'
					break
					;;
				iPhone1,2):
					'iPhone 3G'
					break
					;;
				iPhone2,1):
					'iPhone 3GS'
					break
					;;
				iPhone3,[1-3]):
					'iPhone 4'
					break
					;;
				iPhone4,1):
					'iPhone 4S'
					break
					;;
				iPhone5,[1-2]):
					'iPhone 5'
					break
					;;
				iPhone5,[3-4]):
					'iPhone 5c'
					break
					;;
				iPhone6,[1-2]):
					'iPhone 5s'
					break
					;;
				iPhone7,2):
					'iPhone 6'
					break
					;;
				iPhone7,1):
					'iPhone 6 Plus'
					break
					;;
				iPhone8,1):
					'iPhone 6s'
					break
					;;
				iPhone8,2):
					'iPhone 6s Plus'
					break
					;;
				iPhone8,4):
					'iPhone SE'
					break
					;;
				iPhone9,[13]):
					'iPhone 7'
					break
					;;
				iPhone9,[24]):
					'iPhone 7 Plus'
					break
					;;
				iPhone10,[14]):
					'iPhone 8'
					break
					;;
				iPhone10,[25]):
					'iPhone 8 Plus'
					break
					;;
				iPhone10,[36]):
					'iPhone X'
					break
					;;
				iPhone11,2):
					'iPhone XS'
					break
					;;
				iPhone11,[46]):
					'iPhone XS Max'
					break
					;;
				iPhone11,8):
					'iPhone XR'
					break
					;;
				iPhone12,1):
					'iPhone 11'
					break
					;;
				iPhone12,3):
					'iPhone 11 Pro'
					break
					;;
				iPhone12,5):
					'iPhone 11 Pro Max'
					break
					;;
				iPhone12,8):
					'iPhone SE 2020'
					break
					;;
				iPod1,1):
					'iPod touch'
					break
					;;
				ipod2,1):
					'iPod touch 2G'
					break
					;;
				ipod3,1):
					'iPod touch 3G'
					break
					;;
				ipod4,1):
					break
					;;
					'iPod touch 4G'
				ipod5,1):
					'iPod touch 5G'
					break
					;;
				ipod7,1):
					'iPod touch 6G'
			esac

			model=$_
			break
			;;
		BSD | MINIX)
			model=$(sysctl -n hw.vendor hw.product)
			break
			;;
		Windows)
			model=$(wmic computersystem get manufacturer,model)
			model=${model/Manufacturer}
			model=${model/Model}
			break
			;;
		Solaris)
			model=$(prtconf -b | awk -F':' '/banner-name/ {printf $2}')
			break
			;;
		AIX)
			model=$(/usr/bin/uname -M)
			break
			;;
		FreeMiNT)
			model=$(sysctl -n hw.model)
			model=${model/ (_MCH *)}
			break
			;;
	esac

	# Remove dummy OEM info.
	model=${model//To be filled by O.E.M.}
	model=${model//To Be Filled*}
	model=${model//OEM*}
	model=${model//Not Applicable}
	model=${model//System Product Name}
	model=${model//System Version}
	model=${model//Undefined}
	model=${model//Default string}
	model=${model//Not Specified}
	model=${model//Type1ProductConfigId}
	model=${model//INVALID}
	model=${model//All Series}
	model=${model//�}

	case $model in
		Standard PC*)
			model="KVM/QEMU (${model})"
			break
			;;
		OpenBSD*)
			model="vmm ($model)"
			break
			;;
	esac
}

function get_os {
	case $kernel_name in
		Darwin)
			os=$darwin_name
			break
			;;
		SunOS)
			os='Solaris'
			break
			;;
		Haiku)
			os='Haiku'
			break
			;;
		MINIX)
			os='MINIX'
			break
			;;
		AIX)
			os='AIX'
			break
			;;
		IRIX*)
			os='IRIX'
			break
			;;
		FreeMiNT)
			os='FreeMiNT'
			break
			;;
		Linux | GNU*)
			os='Linux'
			break
			;;
		*BSD | DragonFly | Bitrig)
			os='BSD'
			break
			;;
		CYGWIN* | MSYS* | MINGW*)
			os='Windows'
			break
			;;
		*)
			echo "${red_background}${white}ERROR: Unknown OS detected:" > /dev/stderr
			echo "${red_bold}\t${kernel_name}" > /dev/stderr
			echo 'Aborting...' > /dev/stderr
			echo 'Open an issue on GitHub to add support for your OS.' > /dev/stderr
			exit 1
			;;
	esac
}

function get_packages {
	# to adjust the number of pkgs per pkg manager
	pkgs_h=0

	# has: Check if package manager installed.
	# dir: Count files or dirs in a glob.
	# pac: If packages > 0, log package manager name.
	# tot: Count lines in command output.
	function has {
		type -p "$1" >/dev/null && manager=$1
	}
	function dir {
		((packages+=$#))
		pac "$(($#-pkgs_h))"
	}
	function pac {
		(($1 > 0)) && {
			managers+=("$1 (${manager})")
			manager_string+="${manager}, "
		}
	}
	function tot {
		IFS=$'\n' read -d '' -ra pkgs <<< "$("$@")"
		((packages+=${#pkgs[@]}))
		pac "$((${#pkgs[@]}-pkgs_h))"
	}

	# Redefine tot() for Bedrock Linux.
	[ -f /bedrock/etc/bedrock-release ] && [ $PATH == */bedrock/cross/* ] && {
		function tot {
			IFS=$'\n' read -d '' -ra pkgs <<< "$(for s in $(brl list)
			do
				strat -r "$s" "$@"
			done)"
			((packages+="${#pkgs[@]}"))
			pac "$((${#pkgs[@]}-pkgs_h))"
		}

		br_prefix='/bedrock/strata/*'
	}

	case $os in
		Linux | BSD | iPhone OS | Solaris)
			# Package Manager Programs.
			has kiss && tot kiss l
			has cpt-list && tot cpt-list
			has pacman-key && tot pacman -Qq --color never
			has apt && tot apt list
			has rpm && tot rpm -qa
			has xbps-query && tot xbps-query -l
			has apk && tot apk info
			has opkg && tot opkg list-installed
			has pacman-g2 && tot pacman-g2 -Q
			has lvu && tot lvu installed
			has tce-status && tot tce-status -i
			has pkg_info && tot pkg_info
			has tazpkg && pkgs_h=6 tot tazpkg list && ((packages-=6))
			has sorcery	&& tot gaze installed
			has alps && tot alps showinstalled
			has butch && tot butch list
			has swupd && tot swupd bundle-list --quiet

			# 'mine' conflicts with minesweeper games.
			[ -f /etc/SDE-VERSION ] && has mine && tot mine -q

			# Counting files/dirs.
			# Variables need to be unquoted here. Only Bedrock Linux is affected.
			# $br_prefix is fixed and won't change based on user input so this is safe either way.
			# shellcheck disable=SC2086
			{
				shopt -s nullglob
				has brew && dir "$(brew --cellar)"/*
				has emerge && dir ${br_prefix}/var/db/pkg/*/*/
				has Compile && dir ${br_prefix}/Programs/*/
				has eopkg && dir ${br_prefix}/var/lib/eopkg/package/*
				has crew && dir ${br_prefix}/usr/local/etc/crew/meta/*.filelist
				has pkgtool && dir ${br_prefix}/var/log/packages/*
				has scratch && dir ${br_prefix}/var/lib/scratchpkg/index/*/.pkginfo
				has kagami && dir ${br_prefix}/var/lib/kagami/pkgs/*
				has cave && dir ${br_prefix}/var/db/paludis/repositories/cross-installed/*/data/*/ ${br_prefix}/var/db/paludis/repositories/installed/data/*/
				shopt -u nullglob
			}

			# Other (Needs complex command)
			has kpm-pkg && ((packages+=$(kpm  --get-selections | grep -cv deinstall$)))

			has guix && {
				manager=guix-system && tot guix package -p '/run/current-system/profile' -I
				manager=guix-user   && tot guix package -I
			}

			has nix-store && {
				function nix-user-pkgs {
					nix-store -qR ~/.nix-profile
					nix-store -qR /etc/profiles/per-user/"$USER"
				}

				manager=nix-system && tot nix-store -qR /run/current-system/sw
				manager=nix-user && tot nix-user-pkgs
				manager=nix-default && tot nix-store -qR /nix/var/nix/profiles/default
			}

			# pkginfo is also the name of a python package manager which is painfully slow.
			# TODO: Fix this somehow.
			has pkginfo && tot pkginfo -i

			case $kernel_name in
				FreeBSD | DragonFly)
					has pkg && tot pkg info
					break
					;;
				*)
					has pkg && dir /var/db/pkg/*
					((packages == 0)) && has pkg && tot pkg list
					break
					;;
			esac

			# List these last as they accompany regular package managers.
			has flatpak && tot flatpak list
			has spm && tot spm list -i
			has puyo && dir ~/.puyo/installed

			# Snap hangs if the command is run without the daemon running.
			# Only run snap if the daemon is also running.
			has snap && ps -e | grep -qFm 1 snapd >/dev/null && pkgs_h=1 tot snap list && ((packages-=1))

			# This is the only standard location for appimages.
			# See: https://github.com/AppImage/AppImageKit/wiki
			manager=appimage && has appimaged && dir ~/.local/bin/*.appimage

			break
			;;
		Mac OS X | macOS | MINIX)
			has port && pkgs_h=1 tot port installed && ((packages-=1))
			has brew && dir /usr/local/Cellar/*
			has pkgin && tot pkgin list

			has nix-store && {
				function nix-user-pkgs {
					nix-store -qR ~/.nix-profile
					nix-store -qR /etc/profiles/per-user/"$USER"
				}

				manager=nix-system && tot nix-store -qR /run/current-system/sw
				manager=nix-user && tot nix-store -qR nix-user-pkgs
			}
			break
			;;
		AIX | FreeMiNT)
			has lslpp && ((packages+=$(lslpp -J -l -q | grep -cv '^#')))
			has rpm && tot rpm -qa
			break
			;;
		Windows)
			case $kernel_name in
				CYGWIN*)
					has cygcheck && tot cygcheck -cd
					break
					;;
				MSYS*)
					has pacman   && tot pacman -Qq --color never
					break
					;;
			esac

			# Scoop environment throws errors if `tot scoop list` is used
			has scoop && pkgs_h=1 dir ~/scoop/apps/* && ((packages-=1))

			# Count chocolatey packages.
			[ -d /cygdrive/c/ProgramData/chocolatey/lib ] && dir /cygdrive/c/ProgramData/chocolatey/lib/*

			break
			;;
		Haiku)
			has pkgman && dir /boot/system/package-links/*
			packages=${packages/pkgman/depot}
			break
			;;
		IRIX)
			manager=swpkg
			pkgs_h=3 tot versions -b && ((packages-=3))
			break
			;;
	esac

	if ((packages == 0))
	then
		unset packages
	elif [ $package_managers == on ]
	then
		printf -v packages '%s, ' "${managers[@]}"
		packages=${packages%,*}
	elif [ $package_managers == tiny ]
	then
		packages+=" (${manager_string%,*})"
	fi

	packages=${packages/pacman-key/pacman}
}

# Retrieve the name of the Shell
function get_shell {
	return "${SHELL##*/} "
}

# If the user is using KDE, retrieve the KDE configuration directory
function kde_config_dir {
	if [ "$kde_config_dir" ]
	then
		return
	elif type -p kf5-config &>/dev/null
	then
		kde_config_dir="$(kf5-config --path config)"

	elif type -p kde4-config &>/dev/null
	then
		kde_config_dir="$(kde4-config --path config)"

	elif type -p kde-config &>/dev/null
	then
		kde_config_dir="$(kde-config --path config)"

	elif [ -d "${HOME}/.kde4" ]
	then
		kde_config_dir="${HOME}/.kde4/share/config"

	elif [ -d "${HOME}/.kde3" ]
	then
		kde_config_dir="${HOME}/.kde3/share/config"
	fi

	kde_config_dir="${kde_config_dir/$'/:'*}"
}

cache_uname

path=$(find $HOME -type d -regex '.*dot_files' 2> /dev/null)						# retrieve the path of the repository

get_shell
ln -f -s "${path}/.$?rc" "${HOME}/.$?rc"											# link the Shell's configuration file
sudo ln -f -s "${path}/.$?rc" "/root/.$?rc"

ln -f -s "${path}/.vimrc" "${HOME}/.vimrc"											# link the Vim's configuration files
sudo ln -f -s "${path}/.vimrc" "/root/.vimrc"
ln -f -s "${path}/.vim" "${HOME}/.vim"
sudo ln -f -s "${path}/.vim" "/root/.vim"

ln -f -s "${path}/.gitconfig" "${HOME}/.gitconfig"									# link the Git's configuration files
sudo ln -f -s "${path}/.gitconfig" "/root/.gitconfig"

for i in $(ls "${path}/.config/")													# link the personal configuration files
do
	ln -f -s "${path}/.config/${i}" "${HOME}/.config/${i}"
	sudo ln -f -s "${path}/.config/${i}" "/root/.config/${i}"
done

for i in $(ls "${path}/desktop_entries/")											# link the personal desktop entries
do
	cp "${path}/desktop_entries/${i}" "${HOME}/Desktop/${i}"
	sudo cp "${path}/desktop_entries/${i}" "/root/Desktop/${i}"
done

`${path}/check_IP/install.sh`														# install the check_IP project

exit 0
