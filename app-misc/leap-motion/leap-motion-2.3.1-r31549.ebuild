# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
RESTRICT="fetch mirror test strip"

inherit eutils udev multilib multilib-minimal unpacker

MY_PN="Leap_Motion_Setup_Linux"
MY_PV="${PV/_p/+}"
MY_P="${MY_PN}_${MY_PV}"

DESCRIPTION="Leap Motion Drivers and Library"
HOMEPAGE="http://www.leapmotion.com"
SRC_URI="http://www.leapmotion.com/setup/linux -> ${MY_P}.tgz"

LICENSE="GPL-2" # NOT - totally proprietary - but overlaying license is annoying
SLOT="0"
KEYWORDS="-* ~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="media-libs/mesa
	virtual/glu
	sys-apps/dbus
	x11-libs/libX11
	x11-libs/libXi"

S="${WORKDIR}/Leap_Motion_Installer_Packages_release_public_linux"

QA_TEXTRELS="usr/lib32/Leap/libLeap.so"

multilib_src_configure() {
	local myabi
	case "${ABI}" in
		amd64) myabi="x64";;
		x86) myabi="x86";;
		*) die "No files to support ABI";;
	esac

	einfo "Extracting data.tar.gz from ${P/_p/+}-${myabi}.deb ..."
	unpack_deb "${S}/Leap-${PV}+${PR/r/}-${myabi}.deb"
}

src_compile() {
	:
}

multilib_src_install() {
	cat >"${T}"/99leapmotion <<EOF
QT_PLUGIN_PATH="/usr/$(get_libdir)/Leap"
QT_DEBUG_PLUGINS=1
EOF
	insinto /usr/$(get_libdir)/Leap
	if multilib_is_native_abi ; then
		doins -r usr/lib/Leap/*
		dobin usr/bin/{LeapControlPanel,Recalibrate,Visualizer}
		dosbin usr/sbin/*
		insinto /usr/$(get_libdir)/Leap/platforms
		doins usr/bin/platforms/*
		insinto /usr/share
		doins -r usr/share/*
		udev_dorules lib/udev/rules.d/*
		insinto /usr/share/applications
		doenvd "${T}"/99leapmotion
		rm -f "${ED}"/usr/$(get_libdir)/Leap/libusb-1.0*
	else
		doins usr/lib/Leap/libLeap*
	fi
}

pkg_postinst() {
	udev_reload
}
