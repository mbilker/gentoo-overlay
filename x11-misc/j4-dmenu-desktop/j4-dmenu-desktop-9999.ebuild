# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 cmake

DESCRIPTION="A fast desktop replacement for i3-dmenu-desktop"
HOMEPAGE="https://github.com/enkore/j4-dmenu-desktop"
EGIT_REPO_URI="git://github.com/enkore/j4-dmenu-desktop.git"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+dmenu test"
RESTRICT="!test? ( test )"

DEPEND="test? ( dev-cpp/catch:1 )"
RDEPEND="dmenu? ( x11-misc/dmenu )"

src_prepare() {
	cmake_src_prepare

	# Respect users CFLAGS
	sed -i -e "s/-pedantic -O2//" CMakeLists.txt || die
}

src_configure() {
	local mycmakeargs=(
		-DWITH_TESTS="$(usex test)"
	)

	cmake_src_configure
}

src_install() {
	cmake_src_install

	doman j4-dmenu-desktop.1
}

pkg_postinst() {
	if ! use dmenu; then
		elog "As you have disabled the 'dmenu' use flag,"
		elog "x11-misc/dmenu won't be installed by default."
		elog ""
		elog "Since x11-misc/j4-dmenu-desktop uses x11-misc/dmenu as default,"
		elog "you must configure your own replacement with --dmenu=<command>,"
		elog "as otherwise it won't work."
	fi
}
