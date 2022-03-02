# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

RESTRICT="mirror test strip"

inherit eutils udev unpacker

DESCRIPTION="Connect to Work or Games or Anywhere"
HOMEPAGE="https://parsec.app"
SRC_URI="https://builds.parsecgaming.com/package/parsec-linux.deb -> parsec-linux-${PV}.deb"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="sys-apps/dbus
	x11-libs/libX11
	x11-libs/libXi
	virtual/glu"

S="${WORKDIR}"

src_install() {
	insinto /usr/bin
	dobin usr/bin/parsecd

	insinto /usr/share/icons/hicolor/256x256/apps
	doins usr/share/icons/hicolor/256x256/apps/parsecd.png

	domenu usr/share/applications/parsecd.desktop

	insinto /usr/share
	doins -r usr/share/parsec
}
