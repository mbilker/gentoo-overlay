# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker

DESCRIPTION="Connect to Work or Games or Anywhere"
HOMEPAGE="https://parsec.app"
SRC_URI="https://builds.parsec.app/package/parsec-linux.deb -> parsec-linux-${PV}.deb"

S="${WORKDIR}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="mirror test strip"

RDEPEND="sys-apps/dbus
	x11-libs/libX11
	x11-libs/libXi
	virtual/glu"

src_install() {
	insinto /usr/bin
	dobin usr/bin/parsecd

	insinto /usr/share/icons/hicolor/256x256/apps
	doins usr/share/icons/hicolor/256x256/apps/parsecd.png

	domenu usr/share/applications/parsecd.desktop

	insinto /usr/share
	doins -r usr/share/parsec
}
