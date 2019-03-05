# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PLOCALES="ar ca cs da de el en es fa fr hr hu it ja ko ms nb nl pl pt_BR pt ro ru sr sv tr zh_CN zh_TW"
PLOCALE_BACKUP="en"

inherit cmake-utils eutils gnome2-utils l10n pax-utils toolchain-funcs

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
IUSE="alsa bluetooth +discord doc egl +evdev ffmpeg llvm openal profile pulseaudio +qt5 sdl system-enet upnp"

RDEPEND=">=media-libs/libsfml-2.1
	system-enet? ( >net-libs/enet-1.3.7 )
	>=net-libs/mbedtls-2.1.1
	media-libs/glew:=
	dev-libs/lzo
	media-libs/libao
	media-libs/libpng:=
	sys-libs/glibc
	sys-libs/readline:=
	sys-libs/zlib
	x11-libs/libXext
	x11-libs/libXi
	x11-libs/libXrandr
	virtual/jpeg:=
	virtual/libusb:1
	virtual/opengl
	alsa? ( media-libs/alsa-lib )
	bluetooth? ( net-wireless/bluez )
	egl? ( media-libs/mesa[egl] )
	evdev? (
			dev-libs/libevdev
			virtual/udev
	)
	ffmpeg? ( virtual/ffmpeg )
	llvm? ( sys-devel/llvm:= )
	openal? (
			media-libs/openal
			media-libs/libsoundtouch
	)
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
	>=dev-util/cmake-2.8.8
	>=sys-devel/gcc-5.4.0
	app-arch/zip
	media-libs/freetype
	sys-devel/gettext
	virtual/pkgconfig
	"

src_prepare() {
	# Remove ALL the bundled libraries, aside from:
	# - discord-rpc: For Discord rich-presence, USE flag
	# - gtest: Their build set up solely relies on the build in gtest.
	# - Bochs-disasm: Some dissasembler from Bochs I guess for ARM dissassembly
	# - cubeb: Their build set up makes this not conditional
	# - cpp-optparse: Their build set up makes this not conditional
	# - glslang: Their build set up makes this not conditional
	# - soundtouch: Their build set up makes this not conditional
	# - picojson: For AutoUpdate
	# - pugixml: Their build set up makes this not conditional
	# - xxhash: Not on the tree.
	mv Externals/Bochs_disasm . || die
	mv Externals/cubeb . || die
	mv Externals/cpp-optparse . || die
	mv Externals/FreeSurround . || die
	mv Externals/glslang . || die
	mv Externals/gtest . || die
	mv Externals/imgui . || die
	mv Externals/minizip . || die
	mv Externals/picojson . || die
	mv Externals/pugixml . || die
	mv Externals/soundtouch . || die
	mv Externals/xxhash . || die

	if use discord; then
		mv Externals/discord-rpc . || die
	fi
	if use !system-enet; then
		mv Externals/enet . || die
	fi

	rm -r Externals/* || die "Failed to delete Externals dir."

	mv Bochs_disasm Externals || die
	mv cubeb Externals || die
	mv cpp-optparse Externals || die
	mv FreeSurround Externals || die
	mv glslang Externals || die
	mv gtest Externals || die
	mv imgui Externals || die
	mv minizip Externals || die
	mv picojson Externals || die
	mv pugixml Externals || die
	mv soundtouch Externals || die
	mv xxhash Externals || die

	if use discord; then
		mv discord-rpc Externals || die
	fi
	if use !system-enet; then
		mv enet Externals || die
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

	eapply_user

	cmake-utils_src_prepare
}

src_configure() {
	# Configure cmake
	local mycmakeargs=(
		-DDISTRIBUTOR=Gentoo
		-DENABLE_ALSA="$(usex alsa)"
		-DENABLE_BLUEZ="$(usex bluetooth)"
		-DENABLE_EGL="$(usex egl)"
		-DENABLE_EVDEV="$(usex evdev)"
		-DENABLE_LLVM="$(usex llvm)"
		-DENABLE_PULSEAUDIO="$(usex pulseaudio)"
		-DENABLE_QT="$(usex qt5)"
		-DENABLE_SDL="$(usex sdl)"
		-DUSE_DISCORD_PRESENCE="$(usex discord)"
		-DENCODE_FRAMEDUMPS="$(usex ffmpeg)"
		-DOPROFILING="$(usex profile)"
		-DUSE_SHARED_ENET="$(usex system-enet)"
		-DUSE_UPNP="$(usex upnp)"
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
