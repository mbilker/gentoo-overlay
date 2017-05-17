# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

PLOCALES="ar ca cs da_DK de el en es fa fr hr hu it ja ko ms_MY nb nl pl pt_BR pt ro_RO ru sr sv tr zh_CN zh_TW"
PLOCALE_BACKUP="en"
WX_GTK_VER="3.0"

inherit cmake-utils eutils l10n pax-utils toolchain-funcs versionator wxwidgets

if [[ ${PV} == 9999* ]]
then
	EGIT_REPO_URI="https://github.com/dolphin-emu/dolphin"
	inherit git-r3
	KEYWORDS=""
else
	SRC_URI="https://github.com/${PN}-emu/${PN}/archive/${PV}.zip -> ${P}.zip"
	KEYWORDS="~amd64"
fi

DESCRIPTION="GameCube and Wii game emulator"
HOMEPAGE="https://www.dolphin-emu.org/"

LICENSE="GPL-2"
SLOT="0"
IUSE="alsa ao bluetooth doc egl +evdev ffmpeg llvm openal profile pulseaudio +qt5 sdl system-enet system-portaudio upnp +wxwidgets"

RDEPEND=">=media-libs/libsfml-2.1
	system-enet? ( >net-libs/enet-1.3.7 )
	>=net-libs/mbedtls-2.1.1
	>=media-libs/glew-1.5
	dev-libs/lzo
	media-libs/libpng:=
	sys-libs/glibc
	sys-libs/readline:=
	sys-libs/zlib
	x11-libs/libXext
	x11-libs/libXi
	x11-libs/libXrandr
	virtual/jpeg
	virtual/libusb:1
	virtual/opengl
	alsa? ( media-libs/alsa-lib )
	ao? ( media-libs/libao )
	bluetooth? ( net-wireless/bluez )
	egl? ( media-libs/mesa[egl] )
	evdev? (
			dev-libs/libevdev
			virtual/udev
	)
	ffmpeg? ( virtual/ffmpeg )
	llvm? ( sys-devel/llvm )
	openal? (
			media-libs/openal
			media-libs/libsoundtouch
	)
	system-portaudio? ( media-libs/portaudio )
	profile? ( dev-util/oprofile )
	pulseaudio? ( media-sound/pulseaudio )
	qt5? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtwidgets:5
	)
	sdl? ( media-libs/libsdl2[haptic,joystick] )
	upnp? ( >=net-libs/miniupnpc-1.7 )
	wxwidgets? (
			dev-libs/glib:2
			x11-libs/gtk+:2
			x11-libs/wxGTK:${WX_GTK_VER}[opengl,X]
	)
	"
DEPEND="${RDEPEND}
	>=dev-util/cmake-2.8.8
	>=sys-devel/gcc-5.4.0
	app-arch/zip
	media-libs/freetype
	sys-devel/gettext
	virtual/pkgconfig
	"

src_prepare() {
	# Remove ALL the bundled libraries, aside from:
	# - SOIL: The sources are not public.
	# - gtest: Their build set up solely relies on the build in gtest.
	# - Bochs-disasm: Some dissasembler from Bochs I guess for ARM dissassembly
	# - cpp-optparse: Their build set up makes this not conditional
	# - glslang: Their build set up makes this not conditional
	# - soundtouch: Their build set up makes this not conditional
	# - xxhash: Not on the tree.
	# - portaudio: USE flag
	# - wxWidgets3: 3.1 development version ebuild not available in Portage
	mv Externals/Bochs_disasm . || die
	mv Externals/cpp-optparse . || die
	mv Externals/SOIL . || die
	mv Externals/glslang . || die
	mv Externals/gtest . || die
	mv Externals/soundtouch . || die
	mv Externals/xxhash . || die
	mv Externals/wxWidgets3 . || die

	if use !system-enet; then
		mv Externals/enet . || die
	fi
	if use !system-portaudio; then
		mv Externals/portaudio . || die
	fi

	rm -r Externals/* || die "Failed to delete Externals dir."

	mv Bochs_disasm Externals || die
	mv cpp-optparse Externals || die
	mv SOIL Externals || die
	mv glslang Externals || die
	mv gtest Externals || die
	mv soundtouch Externals || die
	mv xxhash Externals || die
	mv wxWidgets3 Externals || die

	if use !system-enet; then
		mv enet Externals || die
	fi
	if use !system-portaudio; then
		mv portaudio Externals || die
	fi

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
}

src_configure() {
	if use wxwidgets; then
		need-wxwidgets unicode
	fi

	# Configure cmake
	local mycmakeargs=(
		-DDISTRIBUTOR=Gentoo
		$( cmake-utils_use ffmpeg ENCODE_FRAMEDUMPS )
		$( cmake-utils_use profile OPROFILING )
		$( cmake-utils_use_disable wxwidgets WX )
		$( cmake-utils_use_enable alsa ALSA )
		$( cmake-utils_use_enable ao AO )
		$( cmake-utils_use_enable bluetooth BLUEZ )
		$( cmake-utils_use_enable evdev EVDEV )
		$( cmake-utils_use_enable llvm LLVM )
		$( cmake-utils_use_enable openal OPENAL )
		$( cmake-utils_use_enable pulseaudio PULSEAUDIO )
		$( cmake-utils_use_enable qt5 QT2 )
		$( cmake-utils_use_enable sdl SDL )
		$(cmake-utils_use system-enet USE_SHARED_ENET)
		$(cmake-utils_use system-portaudio SYSTEM_PORTAUDIO)
		$( cmake-utils_use_use egl EGL )
		$( cmake-utils_use_use upnp UPNP )
	)

	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_install() {
	# copy files to target installation directory
	cmake-utils_src_install

	# set binary name
	local binary="${PN}"
	use wxwidgets || binary+="-nogui"

	# install documentation as appropriate
	cd "${S}"
	if use doc; then
		dodoc -r docs
	fi

	# create menu entry for GUI builds
	if use wxwidgets; then
		doicon -s 48 Data/dolphin-emu.png
		doicon -s scalable Data/dolphin-emu.svg
		doicon Data/dolphin-emu.svg
	fi
}

pkg_postinst() {
	# Add pax markings for hardened systems
	pax-mark -m "${EPREFIX}"/usr/games/bin/"${PN}"
}
