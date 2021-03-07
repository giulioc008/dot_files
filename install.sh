#!/bin/sh

#####################################################################################################################
#	Filename:		~/Documents/GitHub/dot_files/install.sh															#
#	Purpose:		file that retrieve the info about the machine (DE, distro, kernel, model, OS, package manager	#
#					and shell), append the include of the opportune Shell Script into the Shell's configuration		#
#					file and create the links for the opportune scripts into the opportune paths					#
#	Authors:		Giulio Coa <34110430+giulioc008@users.noreply.github.com> 										#
#	License:		This file is licensed under the LGPLv3.															#
#	Comments:		Based on neofetch source code (https://github.com/dylanaraps/neofetch)							#
#####################################################################################################################

## Colors
red_bold='\[\e[1;31m\]'
red_background='\[\e[41m\]'
white='\[\e[0;37m\]'

reset='\[\e[0m\]'																	# reset the color to the default value

# Cache the output of uname so we don't have to spawn it multiple times.
function cache_uname {
	IFS=' ' read -ra uname <<< "$(uname -srm)"
																					# save the output of the command uname

	kernel_name="${uname[0]}"														# retrieve the kernel's info
	kernel_version="${uname[1]}"
	kernel_machine="${uname[2]}"

	if [ "$kernel_name" == 'Darwin' ]												# check if the kernel is of a macOS's distro
	then
		IFS=$'\n' read -d '' -ra sw_vers <<< "$(awk -F'<|> ' '/key|string/ {print $3}' '/System/Library/CoreServices/SystemVersion.plist')"

		for ((i = 0; i < ${#sw_vers[@]}; i += 2)) {									# cycle on the vector sw_vers to retrieve the kernel's info
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

	unset uname
	unset sw_vers
}

# Retrieve the DE of the OS
function get_de {
	[ $de ] && return																# check if the distro is already set

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

			unset freemint_wm
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

	((${KDE_SESSION_VERSION:-0} > = 4)) && de=${de/KDE/Plasma}
}

# Retrieve the distro of the OS
function get_distro {
	[ $distro ] && return															# check if the distro is already set

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
			elif type -p pveversion > /dev/null
			then
				distro=$(pveversion)
				distro=${distro#pve-manager/}
				distro="Proxmox VE ${distro%/*}"
			elif type -p lsb_release > /dev/null
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
			elif type -p crux > /dev/null
			then
				distro=$(crux)
			elif type -p tazpkg > /dev/null
			then
				distro="SliTaz $(< /etc/slitaz-release)"
			elif type -p kpt > /dev/null && type -p kpm > /dev/null
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
			elif type -p guix > /dev/null
			then
				distro="Guix System $(guix -V | awk 'NR==1{printf $4}')"
			# Display whether using '-current' or '-release' on OpenBSD
			elif [ $kernel_name = 'OpenBSD' ]
			then
				read -ra kernel_info <<< "$(sysctl -n kern.version)"
				distro=${kernel_info[*]:0:2}

				unset kernel_info
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

			unset codename
			unset osx_version
			unset osx_build
			break
			;;
		iPhone OS)
			distro="iOS $osx_version"

			unset osx_version
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
}

# Retrieve the kernel of the OS
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

	unset kernel_version
}

# Retrieve the model of the machine
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

	unset kernel_machine
}

# Retrieve the OS of the machine
function get_os {
	[ $os ] && return																# check if the distro is already set

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

	unset darwin_name
}

# Retrieve the list of the package managers
function get_package_manager {
	[ $managers ] && {
		managers=''
	}																# check if the package manager is already set

	# Check if package manager installed.
	function has {
		type -p "$1" > /dev/null && managers="${managers}$1 "
	}

	case $os in
		Linux | BSD | iPhone OS | Solaris)
			# Package Manager Programs.
			has alps
			has apk
			has apt
			has brew
			has butch
			has cave
			has Compile
			has cpt-list
			has crew
			has emerge
			has eopkg
			has flatpak
			has kagami
			has kiss
			has kpm-pkg
			has lvu
			has opkg
			has pacman-g2
			has pacman-key
			has pkg
			has pkg_info
			has pkgtool
			has puyo
			has rpm
			has scratch
			has snap
			has sorcery
			has spm
			has swupd
			has tazpkg
			has tce-status
			has xbps-query

			# 'mine' conflicts with minesweeper games.
			[ -f /etc/SDE-VERSION ] && has mine

			has guix && {
				managers="${managers}guix-system guix-user "
			}

			has nix-store && {
				managers="${managers}nix-system nix-user nix-default "
			}

			# pkginfo is also the name of a python package manager which is painfully slow.
			# TODO: Fix this somehow.
			has pkginfo

			managers="${managers}appimage " && has appimaged

			break
			;;
		Mac OS X | macOS | MINIX)
			has brew
			has pkgin
			has port

			has nix-store && {
				managers="${managers}nix-system nix-user "
			}
			break
			;;
		AIX | FreeMiNT)
			has lslpp
			has rpm
			break
			;;
		Windows)
			case $kernel_name in
				CYGWIN*)
					has cygcheck
					break
					;;
				MSYS*)
					has pacman
					break
					;;
			esac

			has scoop

			break
			;;
		Haiku)
			has pkgman
			break
			;;
		IRIX)
			managers=swpkg
			break
			;;
	esac

	unset kernel_name
}

# Retrieve the name of the Shell
function get_shell {
	shell="${SHELL##*/}"															# truncate the path of the shell from the last '/'
}

# Trim a string and print it
function trim_quotes {
	trim_output="${1//\'}"
	trim_output="${trim_output//\"}"
	echo $trim_output
}

cache_uname

get_shell																			# retrieve the type of the shell ($shell)
get_os																				# retrieve the OS ($os)
get_distro																			# retrieve the distro of the OS ($distro)
get_kernel																			# retrieve the kernel of the OS ($kernel)
get_de																				# retrieve the DE of the OS ($de)
get_model																			# retrieve the model of the machine ($model)
get_package_manager																	# retrieve the list of the package managers ($managers)

path=$(find $HOME -type d -regex '.*dot_files' 2> /dev/null)						# retrieve the path of the repository

ln -f -s "${path}/.${shell}rc" "${HOME}/.${shell}rc"								# link the Shell's configuration file
sudo ln -f -s "${path}/.${shell}rc" "/root/.${shell}rc"

ln -f -s "${path}/.vimrc" "${HOME}/.vimrc"											# link the Vim's configuration files
sudo ln -f -s "${path}/.vimrc" "/root/.vimrc"
ln -f -s "${path}/.vim" "${HOME}/.vim"
sudo ln -f -s "${path}/.vim" "/root/.vim"

ln -f -s "${path}/.gitconfig" "${HOME}/.gitconfig"									# link the Git's configuration files
sudo ln -f -s "${path}/.gitconfig" "/root/.gitconfig"

for i in $(ls "${path}/.config/" 2> /dev/null)										# link the personal configuration files
do
	ln -f -s "${path}/.config/${i}" "${HOME}/.config/${i}"
	sudo ln -f -s "${path}/.config/${i}" "/root/.config/${i}"
done

for i in $(ls "${path}/desktop_entries/" 2> /dev/null)								# link the personal desktop entries
do
	cp "${path}/desktop_entries/${i}" "${HOME}/Desktop/${i}"
	sudo cp "${path}/desktop_entries/${i}" "/root/Desktop/${i}"
done

`"${path}/check_IP/install.sh"`														# install the check_IP project

exit 0
