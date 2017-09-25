# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

RESTRICT="mirror test strip"

inherit eutils udev unpacker

DESCRIPTION="A modern file manager for power users."
HOMEPAGE="https://fman.io"
#SRC_URI="https://fman.io/updates/arch/fman-${PV}.pkg.tar.xz"
SRC_URI="http://download.fman.io/fman.deb -> fman-${PV}.deb"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="dev-lang/python:3.6=
	>=dev-qt/qtcore-5.6.2
	sys-apps/dbus
	sys-libs/readline
	x11-libs/libX11
	x11-libs/libXi
	virtual/glu"

S="${WORKDIR}"

src_install() {
	insinto /usr/bin
	dobin usr/bin/fman

	insinto /usr/share
	doins -r usr/share/*

	insinto /opt
	doins -r opt/fman

	exeinto /opt/fman
	doexe opt/fman/fman
	doexe opt/fman/lib*.so*
}
