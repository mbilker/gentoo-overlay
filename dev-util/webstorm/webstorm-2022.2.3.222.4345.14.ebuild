# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop wrapper

PV_STRING="$(ver_cut 4-6)"

if ver_test "$(ver_cut 3)" -eq 0; then
	MY_PV="$(ver_cut 1-2)"
else
	MY_PV="$(ver_cut 1-3)"
fi

MY_PN="WebStorm"

DESCRIPTION="A complete toolset for JavaScript development"
HOMEPAGE="https://www.jetbrains.com/webstorm"
SRC_URI="https://download.jetbrains.com/webstorm/${MY_PN}-${MY_PV}.tar.gz -> ${P}.tar.gz"

LICENSE="|| ( IDEA IDEA_Academic IDEA_Classroom IDEA_OpenSource IDEA_Personal )
	Apache-1.1 Apache-2.0 BSD BSD-2 CC0-1.0 CDDL-1.1 CPL-0.5 CPL-1.0
	EPL-1.0 EPL-2.0 GPL-2 GPL-2-with-classpath-exception GPL-3 ISC JDOM
	LGPL-2.1+ LGPL-3 MIT MPL-1.0 MPL-1.1 OFL public-domain PSF-2 UoI-NCSA ZLIB"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="bindist mirror splitdebug"

BDEPEND="dev-util/patchelf"

# RDEPENDS may cause false positives in repoman.
RDEPEND="
	|| (
		>=app-accessibility/at-spi2-core-2.46.0:2
		( app-accessibility/at-spi2-atk dev-libs/atk )
	)
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/freetype:2
	media-libs/mesa
	net-print/cups
	sys-apps/dbus
	x11-libs/cairo
	x11-libs/pango
	sys-libs/zlib
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXtst
	x11-libs/libXxf86vm
	x11-libs/libdrm
	x11-libs/libxcb
	x11-libs/libxkbcommon"

S="${WORKDIR}/${MY_PN}-${PV_STRING}"

QA_PREBUILT="opt/${PN}-${MY_PV}/*"

src_prepare() {
	default

	local remove_me=(
		lib/pty4j-native/linux/aarch64
		lib/pty4j-native/linux/arm
		lib/pty4j-native/linux/mips64el
		lib/pty4j-native/linux/ppc64le
		plugins/remote-dev-server/selfcontained
		plugins/cwm-plugin/quiche-native/linux-aarch64
	)

	use amd64 || remove_me+=( lib/pty4j-native/linux/x86_64 )
	use x86 || remove_me+=( lib/pty4j-native/linux/x86 )

	rm -rv "${remove_me[@]}" || die

	for file in "jbr/lib/"/{libjcef.so,jcef_helper}
	do
		if [[ -f "${file}" ]]; then
			patchelf --set-rpath '$ORIGIN' ${file} || die
		fi
	done
}

src_install() {
	local dir="/opt/${PN}-${MY_PV}"

	insinto "${dir}"
	doins -r *
	fperms 755 "${dir}"/bin/{webstorm.sh,fsnotifier,inspect.sh,ltedit.sh,repair}

	if [[ -d jbr ]]; then
		fperms 755 "${dir}"/jbr/bin/{java,javac,jdb,jrunscript,keytool,rmiregistry,serialver}
		# Fix #763582
		fperms 755 "${dir}"/jbr/lib/{chrome-sandbox,jcef_helper,jexec,jspawnhelper}
	fi

	make_wrapper "${PN}" "${dir}/bin/${PN}.sh"
	newicon "bin/${PN}.svg" "${PN}.svg"
	make_desktop_entry "${PN}" "WebStorm" "${PN}" "Development;IDE;"

	# recommended by: https://confluence.jetbrains.com/display/IDEADEV/Inotify+Watches+Limit
	dodir /usr/lib/sysctl.d/
	echo "fs.inotify.max_user_watches = 524288" > "${D}/usr/lib/sysctl.d/30-webstorm-inotify-watches.conf" || die
}
