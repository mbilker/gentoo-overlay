# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"
RESTRICT="mirror strip test"

inherit eutils unpacker

NDI_VER=4.2

DESCRIPTION="NDI library for OBS Studio"
HOMEPAGE="https://github.com/Palakis/obs-ndi"
SRC_URI="https://github.com/Palakis/obs-ndi/releases/download/${NDI_VER}/libndi3_${PV}-1_amd64.3.deb"

LICENSE="GPL-2" # NOT - totally proprietary - but overlaying license is annoying
SLOT="0"
KEYWORDS="-* ~amd64"
IUSE=""

DEPEND=""
RDEPEND="media-video/obs-studio"

S="${WORKDIR}"

src_install() {
	dolib usr/lib/libndi.so.3
	dosym libndi.so.3 usr/lib/libndi.so
}
