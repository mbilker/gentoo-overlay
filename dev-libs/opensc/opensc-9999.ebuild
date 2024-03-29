# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools bash-completion-r1 libtool

DESCRIPTION="Libraries and applications to access smartcards"
HOMEPAGE="https://github.com/OpenSC/OpenSC/wiki"

if [[ ${PV} != *9999* ]]; then
	SRC_URI="https://github.com/OpenSC/OpenSC/releases/download/${PV}/${P}.tar.gz"
	KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~ppc ~ppc64 ~s390 ~sparc ~x86"
else
	inherit git-r3
	EGIT_REPO_URI="https://github.com/OpenSC/OpenSC.git"
fi

LICENSE="LGPL-2.1"
SLOT="0"
IUSE="ctapi doc openct notify +pcsc-lite readline secure-messaging ssl test zlib"
RESTRICT="!test? ( test )"

RDEPEND="zlib? ( sys-libs/zlib )
	readline? ( sys-libs/readline:0= )
	ssl? ( dev-libs/openssl:0= )
	openct? ( >=dev-libs/openct-0.5.0 )
	pcsc-lite? ( >=sys-apps/pcsc-lite-1.3.0 )
	notify? ( dev-libs/glib:2 )"
DEPEND="${RDEPEND}
	app-text/docbook-xsl-stylesheets
	dev-libs/libxslt
	test? ( dev-util/cmocka )"
BDEPEND="virtual/pkgconfig"

REQUIRED_USE="
	pcsc-lite? ( !openct !ctapi )
	openct? ( !pcsc-lite !ctapi )
	ctapi? ( !pcsc-lite !openct )
	|| ( pcsc-lite openct ctapi )"

src_prepare() {
	default

	eautoreconf
	elibtoolize
}

src_configure() {
	econf \
		--with-completiondir="$(get_bashcompdir)" \
		--disable-openpace \
		--disable-static \
		--disable-strict \
		--enable-man \
		$(use_enable ctapi) \
		$(use_enable doc) \
		$(use_enable notify ) \
		$(use_enable openct) \
		$(use_enable pcsc-lite pcsc) \
		$(use_enable readline) \
		$(use_enable secure-messaging sm) \
		$(use_enable ssl openssl) \
		$(use_enable test cmocka) \
		$(use_enable zlib)
}

src_install() {
	default
	find "${D}" -name '*.la' -delete || die
	insinto /etc/pkcs11/modules/
	doins "${FILESDIR}/${PN}.module"
}
