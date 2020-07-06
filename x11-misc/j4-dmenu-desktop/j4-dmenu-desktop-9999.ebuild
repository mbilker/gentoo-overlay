# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3 cmake-utils

DESCRIPTION="A rewrite of i3-dmenu-desktop, which is much faster"
HOMEPAGE="https://github.com/enkore/j4-dmenu-desktop"
EGIT_REPO_URI="git://github.com/enkore/j4-dmenu-desktop.git"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"
RESTRICT="!test? ( test )"

DEPEND="test? ( dev-cpp/catch:1 )"
RDEPEND="x11-misc/dmenu"

src_prepare() {
	cmake-utils_src_prepare

	# Respect users CFLAGS
	sed -i -e "s/-pedantic -O2//" CMakeLists.txt || die
}

src_configure() {
	local mycmakeargs=(
		-DWITH_TESTS=$(usex test)
	)

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	doman j4-dmenu-desktop.1
}
