# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit eutils autotools gnome2-utils pax-utils

DESCRIPTION="High speed arctic racing game"
HOMEPAGE="http://tuxracer.sourceforge.net/"
SRC_URI="mirror://sourceforge/tuxracer/tuxracer-${PV/_/}.tar.gz
	mirror://sourceforge/tuxracer/tuxracer-data-${PV/_/}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="virtual/opengl
	virtual/glu
	>=media-libs/sdl-sound-1.0.3-r1
	>=media-libs/sdl-mixer-1.2.12-r4[mod]
	>=media-libs/libsfml-2.2"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

#S=${WORKDIR}/etr-${PV/_/}

src_prepare() {
	default
	# kind of ugly in there so we'll do it ourselves
	#sed -i -e '/SUBDIRS/s/resources doc//' Makefile.am || die
	epatch "${FILESDIR}/${P}-include-gl-h-for-glext.patch"
	epatch "${FILESDIR}/${P}-invalid-preprocessing-token.diff"
	eautoreconf
}

src_configure() {
	econf \
		"--with-data-dir=/usr/share/${PN}-data-${PV/_/}"
}

src_install() {
	default
	pax-mark -m "${D}/usr/bin/tuxracer"

	#dodoc doc/{code,courses_events,guide,score_algorithm}
	#doicon -s 48 resources/etr.png
	#doicon -s scalable resources/etr.svg
	doicon "${FILESDIR}/${PN}.xpm"
	#domenu resources/etr.desktop
	domenu "${FILESDIR}/${PN}.desktop"

	cd "${WORKDIR}"
	insinto "/usr/share"
	doins -r "${PN}-data-${PV/_/}"
}

pkg_preinst() {
	gnome2_icon_savelist
}

#pkg_postinst() {
#	gnome2_icon_cache_update
#}

pkg_postrm() {
	gnome2_icon_cache_update
}
