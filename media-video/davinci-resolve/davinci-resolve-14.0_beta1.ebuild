# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit unpacker versionator

DESCRIPTION="Professional A/V post-production software suite"
HOMEPAGE="https://www.blackmagicdesign.com/"
MAJOR_VER="$(get_version_component_range 1-2)"
BASE_NAME="DaVinci_Resolve_${MAJOR_VER}b1_Linux"
ARC_NAME="${BASE_NAME}.zip"
SRC_URI="https://www.blackmagicdesign.com/products/davinciresolve/${ARC_NAME}"

RESTRICT="fetch mirror strip"

KEYWORDS="~amd64"
SLOT="0"
LICENSE="DavinciResolve"

IUSE=""

S="${WORKDIR}"

pkg_nofetch() {
	einfo "Please download"
	einfo "  - ${ARC_NAME}"
	einfo "from ${HOMEPAGE} and place it in ${DISTDIR}"
}

src_unpack() {
	default

	unpacker "./${BASE_NAME}.sh"
}

src_prepare() {
	eapply_user
}

src_install() {
	#mkdir -p "${D}/opt/resolve"
	#echo "RESOLVE_BASE=${D}/opt/resolve" > resolvebase

	dodoc "DaVinci_Resolve_Manual.pdf"
	dodoc "Linux_Installation_Instructions.pdf"

	insinto /opt/resolve
	doins -r Developer
	doins -r UI_Resource
	doins -r rsf/Control
	doins resolvebase

	insinto /opt/resolve/graphics
	doins rsf/DV_Resolve.png

	insinto /usr/share/applications
	doins "${FILESDIR}/davinci-resolve.desktop"

	exeinto /opt/resolve/bin
	doexe "${FILESDIR}/resolve.sh"
	doexe resolve
	doexe panels/DaVinciPanelDaemon
	doexe rsf/bmdpaneld
	doexe rsf/BMDPanelFirmware
	doexe rsf/DPDecoder
	doexe rsf/qt.conf
	doexe rsf/ShowDpxHeader
	doexe rsf/TestIO
	doexe rsf/deviceQuery
	doexe rsf/bandwidthTest
	doexe rsf/oclDeviceQuery
	doexe rsf/oclBandwidthTest

	tar xf panels/libusb-1.0.tgz -C "${D}/opt/resolve/bin"
	tar xf panels/dvpanel-utility-linux-x86_64.tgz -C "${D}/opt/resolve"

	cp -r LUT "${D}/opt/resolve"
	cp -r Onboarding "${D}/opt/resolve"
	cp -r plugins "${D}/opt/resolve"

	gunzip -f "${D}/opt/resolve/LUT/trim_lut0.dpx.gz"

	mkdir "${D}/opt/resolve/libs"
	rm libs/libcuda.so*
	for archive in libs/*tgz; do
		tar xf "${archive}" -C "${D}/opt/resolve/libs"
		rm "${archive}"
	done
	tar xf panels/dvpanel-framework-linux-x86_64.tgz -C "${D}/opt/resolve/libs"
	cp -r libs/* "${D}/opt/resolve/libs"
	ln -s /usr/lib64/libcrypto.so	"${D}/opt/resolve/libs/libcrypto.so.10"
	ln -s /usr/lib64/libssl.so	"${D}/opt/resolve/libs/libssl.so.10"
	ln -s /usr/lib64/libgstbase-0.10.so	"${D}/opt/resolve/libs/libgstbase-0.10.so.0"
	ln -s /usr/lib64/libgstreamer-0.10.so	"${D}/opt/resolve/libs/libgstreamer-0.10.so.0"

	#./install.sh
}
