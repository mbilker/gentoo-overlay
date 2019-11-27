# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson

DESCRIPTION="Userspace Out-Of-Memory (OOM) killer for linux systems"
HOMEPAGE="https://github.com/facebookincubator/oomd"
SRC_URI="https://github.com/facebookincubator/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="mirror"
DEPEND="dev-libs/jsoncpp"

src_configure() {
	meson_src_configure
}

src_install() {
	meson_src_install
}
