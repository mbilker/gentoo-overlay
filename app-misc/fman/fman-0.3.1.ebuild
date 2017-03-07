# $Header: $

EAPI="5"
RESTRICT="mirror test strip"

inherit eutils udev unpacker

DESCRIPTION="A modern file manager for power users."
HOMEPAGE="https://fman.io"
SRC_URI="http://download.fman.io/fman.deb"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="-* amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="virtual/glu
	sys-apps/dbus
	x11-libs/libX11
	x11-libs/libXi"

#QA_TEXTRELS="usr/lib32/Leap/libLeap.so"

src_configure() {
	einfo "Extracting data.tar.gz from ${P}.deb ..."
	unpack_deb "${S}/${P}.deb"
}

src_compile() {
	:
}

src_install() {
	insinto /usr/bin
	dobin usr/bin/fman
	dobin usr/bin/update-fman

	insinto /usr/share
	doins -r usr/share/*

	insinto /opt
	doins -r opt/fman
}
