# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# Instructions from https://aur.archlinux.org/packages/ttf-ms-win10
#
# Instructions were copied from ttf-ms-win8 and slightly modified:
#
# BUILD INSTRUCTIONS:
# -------------------
#
# Please note, that usage of Microsoft fonts outside running Windows
# system is prohibited by EULA (although in certain countries EULA is invalid).
# Please consult Microsoft license before using fonts.
#
# You can acquire fonts either from an installed and up-to-date Windows 10
# system or the most recent install medium.
#
# On the installed Windows 10 system fonts are usually located in
#       C:\Windows\Fonts
# and license file is
#       C:\Windows\System32\Licenses\neutral\_Default\Core\license.rtf
#
# How to acquire fonts from Windows 10 install medium:
#
#    You can freely download the Windows 10 Enterprise 90-day evaluation from:
#
#       http://www.microsoft.com/en-us/evalcenter/evaluate-windows-10-enterprise
#
#    Fonts are located in 'sources/install.wim' file on the ISO, which
#    is a 'Windows Imaging Format' (WIM) archive.
#
#    You can extract WIM using wimextract ('wimlib' package from AUR) or
#    7z ('p7zip').
#
#    Put the following script together with previously extracted
#    'install.wim' and execute:
#
#       wimextract install.wim 1 /Windows/{Fonts/"*".{ttf,ttc},System32/Licenses/neutral/"*"/"*"/license.rtf} --dest-dir fonts
#
#    Fonts and license will be located in the 'fonts' dir.
#
# You need all files listed in the _ttf_ms_win10[_*] arrays.Place them in the
# same directory as this PKGBUILD file, then run makepkg.

EAPI=7

inherit font

DESCRIPTION="Microsoft Windows 10 TrueType fonts"
HOMEPAGE="http://www.microsoft.com/typography/fonts/product.aspx?PID=164"
SRC_URI="${P}.tar.bz2"
RESTRICT="fetch"

LICENSE="MicrosoftEULA"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND=""

S="${WORKDIR}/${P}"
FONT_S="${WORKDIR}/${P}"
FONT_SUFFIX="ttf ttc"
