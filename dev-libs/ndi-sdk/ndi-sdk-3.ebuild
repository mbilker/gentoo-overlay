# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"
RESTRICT="fetch mirror strip test"

inherit eutils unpacker

NDI_VERSION=3

DESCRIPTION="NDI SDK for Video Applications"
HOMEPAGE="https://www.newtek.com/ndi/"
SRC_URI="InstallNDISDK_v${NDI_VERSION}_Linux.sh"

LICENSE="GPL-2" # NOT - totally proprietary - but overlaying license is annoying
SLOT="0"
KEYWORDS="-* ~amd64"
IUSE=""

DEPEND=""
RDEPEND=""

S="${WORKDIR}/NDI SDK for Linux"

src_unpack() {
	cd "${WORKDIR}"
	yes | sh "${DISTDIR}"/InstallNDISDK_v"${NDI_VERSION}"_Linux.sh || die "Extract failed"
}

src_install() {
	mkdir -p "${D}"/opt
	cp -r "${S}" "${D}"/opt/ndi
}
