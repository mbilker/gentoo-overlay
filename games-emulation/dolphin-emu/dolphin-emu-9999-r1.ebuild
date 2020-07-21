# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PLOCALES="ar ca cs da de el en es fa fr hr hu it ja ko ms nb nl pl pt_BR pt ro ru sr sv tr zh_CN zh_TW"
PLOCALE_BACKUP="en"

inherit cmake eutils gnome2-utils l10n pax-utils toolchain-funcs

if [[ ${PV} == *9999 ]]
then
	EGIT_REPO_URI="https://github.com/dolphin-emu/dolphin"
	inherit git-r3
else
	SRC_URI="https://github.com/${PN}-emu/${PN}/archive/${PV}.zip -> ${P}.zip"
	KEYWORDS="~amd64"
fi

DESCRIPTION="GameCube and Wii game emulator"
HOMEPAGE="https://www.dolphin-emu.org/"

LICENSE="GPL-2"
SLOT="0"
IUSE="alsa bluetooth +discord doc +evdev ffmpeg llvm log lto profile pulseaudio +qt5 sdl upnp"

RDEPEND="
	dev-libs/hidapi:0=
	dev-libs/lzo
	media-libs/glew:=
	media-libs/libao
	media-libs/libpng:0=
	media-libs/libsfml
	media-libs/mesa[egl]
	net-libs/enet:1.3
	net-libs/mbedtls
	sys-libs/glibc
	sys-libs/readline:0=
	sys-libs/zlib:0=
	x11-libs/libXext
	x11-libs/libXi
	x11-libs/libXrandr
	virtual/jpeg:=
	virtual/libusb:1
	virtual/opengl
	alsa? ( media-libs/alsa-lib )
	bluetooth? ( net-wireless/bluez )
	evdev? (
			dev-libs/libevdev
			virtual/udev
	)
	ffmpeg? ( virtual/ffmpeg )
	llvm? ( sys-devel/llvm:= )
	profile? ( dev-util/oprofile )
	pulseaudio? ( media-sound/pulseaudio )
	qt5? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtwidgets:5
	)
	sdl? ( media-libs/libsdl2[haptic,joystick] )
	upnp? ( >=net-libs/miniupnpc-1.7 )
"
DEPEND="${RDEPEND}
	app-arch/zip
	media-libs/freetype
	sys-devel/gettext
	virtual/pkgconfig"

src_prepare() {
	cmake_src_prepare

	# Remove all the bundled libraries that support system-installed
	# preference. See CMakeLists.txt for conditional 'add_subdirectory' calls.
	local KEEP_SOURCES=(
		Bochs_disasm
		FreeSurround
		cpp-optparse
		# no support for using system library
		fmt
		glslang
		imgui
		minizip
		# FIXME: xxhash cannot be found by cmake
		xxhash
		# soundtouch uses shorts, not floats
		soundtouch
		cubeb
		# Their build setup solely relies on the build in gtest
		gtest
		# gentoo's version requies exception support.
		# dolphin disables exceptions and fails the build.
		picojson
		# dolphin uses an older version of the headers
		Vulkan
	)

	if use discord; then
		KEEP_SOURCES+=(discord-rpc)
	fi

	local s
	for s in "${KEEP_SOURCES[@]}"; do
		mv -v "Externals/${s}" . || die
	done
	einfo "removing sources: $(echo Externals/*)"
	rm -r Externals/* || die "Failed to delete Externals dir."
	for s in "${KEEP_SOURCES[@]}"; do
		mv -v "${s}" "Externals/" || die
	done

	remove_locale() {
		# Ensure preservation of the backup locale when no valid LINGUA is set
		if [[ "${PLOCALE_BACKUP}" == "${1}" ]] && [[ "${PLOCALE_BACKUP}" == "$(l10n_get_locales)" ]]; then
			return
		else
			rm "Languages/po/${1}.po" || die
		fi
	}

	l10n_find_plocales_changes "Languages/po/" "" '.po'
	l10n_for_each_disabled_locale_do remove_locale

	eapply_user
}

src_configure() {
	local mycmakeargs=(
		# Use ccache only when user did set FEATURES=ccache (or similar)
		# not when ccache binary is present in system (automagic).
		-DCCACHE_BIN=CCACHE_BIN-NOTFOUND
		-DDISTRIBUTOR=Gentoo
		-DENABLE_ALSA="$(usex alsa)"
		-DENABLE_BLUEZ="$(usex bluetooth)"
		-DENABLE_EVDEV="$(usex evdev)"
		-DENABLE_LLVM="$(usex llvm)"
		-DENABLE_PULSEAUDIO="$(usex pulseaudio)"
		-DENABLE_QT="$(usex qt5)"
		-DENABLE_SDL="$(usex sdl)"
		-DENCODE_FRAMEDUMPS="$(usex ffmpeg)"
		-DFASTLOG=$(usex log)
		-DOPROFILING="$(usex profile)"
		-DUSE_DISCORD_PRESENCE="$(usex discord)"
		-DUSE_SHARED_ENET=ON
		-DUSE_UPNP="$(usex upnp)"
	)

	cmake_src_configure
}

src_install() {
	# copy files to target installation directory
	cmake_src_install

	# set binary name
	local binary="${PN}"
	use qt5 || binary+="-nogui"

	# install documentation as appropriate
	cd "${S}"
	if use doc; then
		dodoc -r docs
	fi

	# create menu entry for GUI builds
	if use qt5; then
		doicon -s 48 Data/dolphin-emu.png
		doicon -s scalable Data/dolphin-emu.svg
		doicon Data/dolphin-emu.svg
	fi
}

pkg_postinst() {
	# Add pax markings for hardened systems
	pax-mark -m "${EPREFIX}"/usr/games/bin/"${PN}"
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
