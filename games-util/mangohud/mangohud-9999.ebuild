# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..11} )

inherit meson multilib-minimal python-any-r1

DESCRIPTION="A Vulkan and OpenGL overlay for monitoring FPS, temperatures, CPU/GPU load and more."
HOMEPAGE="https://github.com/flightlessmango/MangoHud"

IMGUI_VER="1.81"
VULKAN_HEADERS_VER="1.2.158"

IMGUI_SRC_URI="
	https://github.com/ocornut/imgui/archive/v${IMGUI_VER}.tar.gz -> ${PN}-imgui-${IMGUI_VER}.tar.gz
	https://wrapdb.mesonbuild.com/v1/projects/imgui/${IMGUI_VER}/1/get_zip -> ${PN}-imgui-wrap-${IMGUI_VER}.zip
"
VULKAN_HEADERS_SRC_URI="
	https://github.com/KhronosGroup/Vulkan-Headers/archive/v${VULKAN_HEADERS_VER}.tar.gz -> ${PN}-vulkan-headers-${VULKAN_HEADERS_VER}.tar.gz
	https://wrapdb.mesonbuild.com/v2/vulkan-headers_${VULKAN_HEADERS_VER}-2/get_patch -> ${PN}-vulkan-headers-wrap-${VULKAN_HEADERS_VER}.zip
"

if [[ ${PV} == "9999" ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/flightlessmango/MangoHud.git"
	SRC_URI="
		${IMGUI_SRC_URI}
		${VULKAN_HEADERS_SRC_URI}
	"
else
	SRC_URI="
		https://github.com/flightlessmango/MangoHud/archive/v${PV}-1.tar.gz -> ${P}.tar.gz
		${IMGUI_SRC_URI}
		${VULKAN_HEADERS_SRC_URI}
	"
	KEYWORDS="-* ~amd64 ~x86"
fi

LICENSE="MIT"
SLOT="0"
IUSE="+dbus debug +X xnvctrl wayland video_cards_nvidia"

REQUIRED_USE="
	|| ( X wayland )
	xnvctrl? ( video_cards_nvidia )"

BDEPEND="
	$(python_gen_any_dep 'dev-python/mako[${PYTHON_USEDEP}]')
"

python_check_deps() {
	python_has_version "dev-python/mako[${PYTHON_USEDEP}]"
}

DEPEND="
	dev-cpp/nlohmann_json[${MULTILIB_USEDEP}]
	dev-libs/spdlog[${MULTILIB_USEDEP}]
	dev-util/glslang
	media-libs/glew[${MULTILIB_USEDEP}]
	media-libs/glfw[${MULTILIB_USEDEP}]
	media-libs/vulkan-loader[${MULTILIB_USEDEP}]
	media-libs/libglvnd[$MULTILIB_USEDEP]
	dbus? ( sys-apps/dbus[${MULTILIB_USEDEP}] )
	X? ( x11-libs/libX11[${MULTILIB_USEDEP}] )
	video_cards_nvidia? (
		x11-drivers/nvidia-drivers[${MULTILIB_USEDEP}]
		xnvctrl? ( x11-drivers/nvidia-drivers[static-libs] )
	)
	wayland? ( dev-libs/wayland[${MULTILIB_USEDEP}] )
"

RDEPEND="${DEPEND}"

[[ "$PV" != "9999" ]] && S="${WORKDIR}/MangoHud-${PV}"

src_unpack() {
	default
	[[ $PV == 9999 ]] && git-r3_src_unpack
}

src_prepare() {
	# Both of the imgui and the Vulkan headers archives use the same
	# folder name, so we don't need to rename anything. Just move the
	# folders to the appropriate location.
	mv "${WORKDIR}/imgui-${IMGUI_VER}" "${S}/subprojects" || die
	mv "${WORKDIR}/Vulkan-Headers-${VULKAN_HEADERS_VER}" "${S}/subprojects" || die

	eapply_user
}

multilib_src_configure() {
	local emesonargs=(
		-Dappend_libdir_mangohud=false
		-Duse_system_spdlog=enabled
		-Dinclude_doc=false
		$(meson_feature video_cards_nvidia with_nvml)
		$(meson_feature xnvctrl with_xnvctrl)
		$(meson_feature X with_x11)
		$(meson_feature wayland with_wayland)
		$(meson_feature dbus with_dbus)
		-Dmangoapp=true
		-Dmangohudctl=true
		-Dmangoapp_layer=true
	)
	meson_src_configure
}

multilib_src_compile() {
	meson_src_compile
}

multilib_src_install() {
	meson_src_install
}

multilib_src_install_all() {
	dodoc "${S}/data/MangoHud.conf"

	einstalldocs
}

pkg_postinst() {
	if ! use xnvctrl; then
		einfo ""
		einfo "If mangohud can't get GPU load, or other GPU information,"
		einfo "and you have an older Nvidia device."
		einfo ""
		einfo "Try enabling the 'xnvctrl' useflag."
		einfo ""
	fi
}
