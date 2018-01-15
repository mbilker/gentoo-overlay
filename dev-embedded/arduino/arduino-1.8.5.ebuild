# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
JAVA_PKG_IUSE="doc examples"

inherit gnome2-utils java-pkg-2 java-ant-2

DESCRIPTION="An open-source AVR electronics prototyping platform"
HOMEPAGE="http://arduino.cc/ https://github.com/arduino/"
SRC_URI="
	https://github.com/arduino/Arduino/archive/${PV}.tar.gz -> arduino-src-${PV}.tar.gz
	mirror://gentoo/arduino-icons.tar.bz2
"

LICENSE="GPL-2 GPL-2+ LGPL-2 CC-BY-SA-3.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="strip binchecks"

S="${WORKDIR}/Arduino-${PV}"

CDEPEND="
	dev-java/jna:0"

RDEPEND="
	${CDEPEND}
	>=virtual/jre-1.8"

DEPEND="
	${CDEPEND}
	>=virtual/jdk-1.8"

EANT_GENTOO_CLASSPATH="jna"
EANT_EXTRA_ARGS="-Dversion=${PV}"
EANT_BUILD_TARGET="build"
JAVA_ANT_REWRITE_CLASSPATH="yes"

src_compile() {
	eant "${EANT_EXTRA_ARGS}" -f build/build.xml
}

src_install() {
	# Install the whole Arduino environment to /opt
	mkdir -p "${D}"/opt/"${P}"
	cp -a "${S}"/build/linux/work/. "${D}"/opt/"${P}"/

	dosym "/opt/${P}/arduino" /usr/bin/arduino

	cd "${S}"/build/linux/work || die

	if use examples; then
		java-pkg_doexamples examples
		docompress -x /usr/share/doc/${PF}/examples/
	fi

	if use doc; then
		DOCS=( revisions.txt "${S}"/readme.txt )
		HTML_DOCS=( reference )
		einstalldocs
		java-pkg_dojavadoc "${S}"/build/javadoc/everything
	fi

	# install menu and icons
	domenu "${FILESDIR}/${PN}.desktop"
	for sz in 16 24 32 48 128 256; do
		newicon -s $sz \
			"${WORKDIR}/${PN}-icons/debian_icons_${sz}x${sz}_apps_${PN}.png" \
			"${PN}.png"
	done
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
