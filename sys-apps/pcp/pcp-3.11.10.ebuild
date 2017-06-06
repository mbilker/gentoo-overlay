# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit flag-o-matic

DESCRIPTION="A framework and services to support system-level performance monitoring and performance management"
HOMEPAGE="http://pcp.io"
SRC_URI="https://github.com/performancecopilot/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
DEPEND=""
RDEPEND=""

src_configure() {
	filter-flags -fomit-frame-pointer
	econf || die "econf failed"
}
src_compile() {
	emake -j1 || die "emake failed"
}

src_install() {
	DIST_ROOT="${D}" emake install || die "emake install failed"
	dodoc CHANGELOG README
}
