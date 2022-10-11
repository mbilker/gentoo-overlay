# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

# This is the name of the latest release branch.
#RELEASE="release-R105-14989.B"
# This is the latest commit in the release-R105-14989.B branch.
GIT_SHA1="a975eed306e16947c30b48ccd25ab67a37295742"

DESCRIPTION="Chrome OS verified boot tools"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/vboot_reference/ https://dev.chromium.org/chromium-os/chromiumos-design-docs/verified-boot"
#SRC_URI="https://chromium.googlesource.com/chromiumos/platform/vboot_reference/+archive/refs/heads/${RELEASE}.tar.gz -> ${P}.tar.gz"
SRC_URI="https://chromium.googlesource.com/chromiumos/platform/vboot_reference/+archive/${GIT_SHA1}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~mips ~x86"
IUSE="+libzip minimal static"

LIB_DEPEND="
	dev-libs/libyaml:=[static-libs(+)]
	app-arch/xz-utils:=[static-libs(+)]"
LIB_DEPEND_MINIMAL="
	elibc_musl? ( sys-libs/fts-standalone:=[static-libs(+)] )
	dev-libs/openssl:0=[static-libs(+)]
	libzip? ( dev-libs/libzip:=[static-libs(+)] )
	sys-apps/util-linux:=[static-libs(+)]"
RDEPEND="!static? (
		${LIB_DEPEND_MINIMAL//\[static-libs(+)]}
		!minimal? ( ${LIB_DEPEND//\[static-libs(+)]} )
	)"
DEPEND="${RDEPEND}
	static? (
		${LIB_DEPEND_MINIMAL}
		!minimal? ( ${LIB_DEPEND} )
	)
	app-crypt/trousers
	sys-apps/flashrom"
BDEPEND="virtual/pkgconfig"

S=${WORKDIR}

#PATCHES=(
#	# Bug #687820
#	"${FILESDIR}"/${PN}-80-musl-fts.patch
#)

src_prepare() {
	default

	# Bug #687008
	if ! use libzip; then
		sed -e 's|^\(LIBZIP_VERSION :=\).*|\1|' -i Makefile || die
	fi

	sed -i \
		-e 's:${DESTDIR}/\(bin\|include\|${LIBDIR}\|share\):${DESTDIR}/usr/\1:g' \
		-e 's:${DESTDIR}/default:${DESTDIR}/etc/default:g' \
		-e 's:${TEST_INSTALL_DIR}/bin:${TEST_INSTALL_DIR}/usr/bin:' \
		Makefile || die
	sed -e 's:^BIN_DIR=${BUILD_DIR}/install_for_test/bin:BIN_DIR=${BUILD_DIR}/install_for_test/usr/bin:' \
		-i tests/common.sh || die
}

_emake() {
	local arch=$(tc-arch)
	emake \
		V=1 \
		QEMU_ARCH= \
		ARCH=${arch} \
		HOST_ARCH=${arch} \
		LIBDIR="$(get_libdir)" \
		DEBUG_FLAGS= \
		WERROR= \
		MINIMAL=$(usev minimal) \
		STATIC=$(usev static) \
		$(usex elibc_musl HAVE_MUSL=1 "") \
		"$@"
}

src_compile() {
	tc-export CC AR CXX PKG_CONFIG
	_emake FUZZ_TEST_BINS= TEST_BINS= all
}

src_test() {
	_emake runtests
}

src_install() {
	_emake DESTDIR="${ED}" install install_dev

	insinto /usr/share/vboot/devkeys
	doins tests/devkeys/*

	dodoc README
}
