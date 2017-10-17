# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils autotools multilib-build

DESCRIPTION="Large collection of LADSPA audio plugins/effects"
HOMEPAGE="http://plugin.org.uk"
SRC_URI="https://github.com/swh/ladspa/archive/v${PV}.tar.gz -> ${P}.tar.gz"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~ppc ~x86 ~amd64-linux ~x86-linux"
IUSE="cpu_flags_x86_3dnow nls cpu_flags_x86_sse"

RDEPEND="
	>=media-sound/gsm-1.0.13-r1[${MULTILIB_USEDEP}]
	>=sci-libs/fftw-3.3.3-r2[${MULTILIB_USEDEP}]
	abi_x86_32? ( !<=app-emulation/emul-linux-x86-soundlibs-20130224-r2
					!app-emulation/emul-linux-x86-soundlibs[-abi_x86_32(-)] )"
DEPEND="${RDEPEND}
	media-libs/ladspa-sdk
	sys-devel/gettext
	virtual/pkgconfig"

DOCS=( AUTHORS ChangeLog README TODO )

S="${WORKDIR}/ladspa-${PV}"

src_prepare() {
	epatch "${FILESDIR}/${P}-pic.patch"
	epatch "${FILESDIR}/${P}-glibc-2.10.patch"

	# Use system libgsm, bug #252890
	rm -rf gsm
	epatch "${FILESDIR}/${P}-system_gsm.patch"

	# This is to update gettext macros, otherwise they are incompatible with
	# recent libtools, bug #231767
	autopoint -f || die

	# it doesn't get updated otherwise
	rm -f missing

	# old shipped version breaks multilib build #475022
	rm -f config.h

	# Fix build with automake 1.13
	#sed -i 's/AM_CONFIG_HEADER/AC_CONFIG_HEADERS/g' configure.ac || die

	eapply_user

	eautoreconf
	elibtoolize
}

multilib_src_configure() {
	ECONF_SOURCE="${S}" econf \
		$(use_enable cpu_flags_x86_sse sse) \
		$(use_enable cpu_flags_x86_3dnow 3dnow) \
		$(use_enable nls) \
		--enable-fast-install \
		--disable-dependency-tracking
}

pkg_postinst() {
	ewarn "WARNING: You have to be careful when using the"
	ewarn "swh plugins. Be sure to lower your sound volume"
	ewarn "and then play around a bit with the plugins so"
	ewarn "you get a feeling for it. Otherwise your speakers"
	ewarn "won't like that."
}
