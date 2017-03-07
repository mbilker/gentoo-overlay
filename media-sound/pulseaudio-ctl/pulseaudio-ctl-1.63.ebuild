# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

DESCRIPTION="Control pulseaudio volume from the shell or mapped to keyboard shortcuts."
HOMEPAGE="https://github.com/graysky2/pulseaudio-ctl"
SRC_URI="http://repo-ck.com/source/${PN}/${P}.tar.xz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=media-sound/pulseaudio-8.0
"
RDEPEND="${DEPEND}"

src_configure() {
	emake
}

src_install() {
	emake install DESTDIR="${D}"
}
