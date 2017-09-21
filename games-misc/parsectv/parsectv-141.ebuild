# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

RESTRICT="mirror test strip"

inherit eutils udev unpacker

DESCRIPTION="A modern file manager for power users."
HOMEPAGE="https://fman.io"
SRC_URI="https://s3.amazonaws.com/parsec-build/package/parsec-linux.deb -> parsec-linux-${PV}.deb"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND=">=media-sound/sndio-1.2.0
	sys-apps/dbus
	x11-libs/libX11
	x11-libs/libXi
	virtual/glu"

S="${WORKDIR}"

src_install() {
	insinto /usr/bin
	dobin usr/bin/parsec

	insinto /usr/share/icons/hicolor/256x256/apps
	doins usr/share/icons/hicolor/256x256/apps/parsec.png

	domenu usr/share/applications/parsec.desktop
}
