# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit multilib-minimal

DESCRIPTION="FFmpeg version of headers required to interface with Nvidias codec APIs"
HOMEPAGE="https://git.videolan.org/?p=ffmpeg/nv-codec-headers.git"

if [[ ${PV} != *9999* ]]; then
	SRC_URI=""
	KEYWORDS=""
else
	EGIT_REPO_URI="https://git.videolan.org/git/ffmpeg/nv-codec-headers.git"
	inherit git-r3
fi

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}
	>=x11-drivers/nvidia-drivers-390.25[${MULTILIB_USEDEP}]
"

S="${WORKDIR}/${P}"

src_prepare() {
	multilib_copy_sources
	default
}

multilib_src_compile() {
	emake PREFIX="${EPREFIX}/usr" LIBDIR="$(get_libdir)"
}

multilib_src_install() {
	emake PREFIX="${EPREFIX}/usr" LIBDIR="$(get_libdir)" DESTDIR="${D}" install
}
