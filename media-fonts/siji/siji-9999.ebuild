# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit font git-r3

DESCRIPTION="Siji is an iconic bitmap font based on the Stlarch font with additional glyphs."
HOMEPAGE="https://github.com/stark/siji"
EGIT_REPO_URI="https://github.com/stark/siji"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="plugins"

DEPEND="plugins? ( x11-apps/xfd )"
RDEPEND=""

S="${WORKDIR}/${P}/pcf"
FONT_S="${WORKDIR}/${P}/pcf"
FONT_SUFFIX="pcf"

pkg_preinst() {
	if use plugins; then
		mv -f "${WORKDIR}/${P}/view.sh" "${PN}_view"
		dobin "${PN}_view"
	fi
}
