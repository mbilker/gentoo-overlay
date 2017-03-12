# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

PLOCALES="ar ca cs da_DK de el en es fa fr hr hu it ja ko ms_MY nb nl pl pt_BR pt ro_RO ru sr sv tr zh_CN zh_TW"
PLOCALE_BACKUP="en"
WX_GTK_VER="3.0"

inherit cmake-utils eutils l10n pax-utils toolchain-funcs versionator wxwidgets git-r3

DESCRIPTION="Nintendo GameCube and Wii emulator"
HOMEPAGE="http://www.dolphin-emu.org/"
SRC_URI=""
EGIT_REPO_URI="https://github.com/dolphin-emu/dolphin"

LICENSE="GPL-2"
SLOT="0"
IUSE="alsa ao bluetooth doc encode openal portaudio pulseaudio +wxwidgets"

RDEPEND=">=media-libs/glew-1.5
	>=media-libs/libsdl-1.2[joystick]
	dev-libs/lzo
	media-libs/libpng:=
	sys-libs/glibc
	sys-libs/readline:=
	sys-libs/zlib
	x11-libs/libXext
	x11-libs/libXi
	x11-libs/libXrandr
	ao? ( media-libs/libao )
	alsa? ( media-libs/alsa-lib )
	bluetooth? ( net-wireless/bluez )
	encode? ( media-video/ffmpeg[encode] )
	openal? ( media-libs/openal )
	virtual/opengl
	portaudio? ( media-libs/portaudio )
	pulseaudio? ( media-sound/pulseaudio )
	virtual/jpeg
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

src_configure() {
	# Configure cmake
	mycmakeargs="
		-DDOLPHIN_WC_REVISION=9999
		$(cmake-utils_use !wxwidgets DISABLE_WX)
		$(cmake-utils_use alsa ENABLE_ALSA)
		$(cmake-utils_use ao ENABLE_AO)
		$(cmake-utils_use pulseaudio ENABLE_PULSEAUDIO)
		$(cmake-utils_use openal ENABLE_OPENAL)
		$(cmake-utils_use bluetooth ENABLE_BLUEZ)
		$(cmake-utils_use encode ENCODE_FRAMEDUMPS)"


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
		#doicon Source/Core/DolphinWX/resources/Dolphin.xpm || die
		#make_desktop_entry "${binary}" "Dolphin" "Dolphin" "Game;Emulator"
	fi

	#prepgamesdirs
}

pkg_postinst() {
	# Add pax markings for hardened systems
	pax-mark -m "${EPREFIX}"/usr/games/bin/"${PN}"

	if ! use portaudio; then
		ewarn "If you want microphone capabilities in dolphin-emu, rebuild with"
		ewarn "USE=\"portaudio\""
	fi
	if ! use wxwidgets; then
		ewarn "Note: It is not currently possible to configure Dolphin without the GUI."
		ewarn "Rebuild with USE=\"wxwidgets\" to enable the GUI if needed."
	fi

	#games_pkg_postinst
}
