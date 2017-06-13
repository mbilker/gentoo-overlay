# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit flag-o-matic user

DESCRIPTION="Services and framework for system-level performance monitoring and management"
HOMEPAGE="http://pcp.io"
SRC_URI="https://github.com/performancecopilot/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="amd64 ~x86"
IUSE="+webapi"
DEPEND="webapi? ( net-libs/libmicrohttpd )"
RDEPEND=""

pkg_setup() {
	enewgroup pcp
	enewuser pcp -1 -1 /var/lib/pcp pcp
}

src_configure() {
	filter-flags -fomit-frame-pointer
	econf \
		$(use_with webapi)
}

src_install() {
	DIST_ROOT="${D}" emake install || die "emake failed"
	dodoc CHANGELOG README.md
}
