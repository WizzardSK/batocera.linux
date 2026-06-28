################################################################################
#
# libretro-squirreljme
#
################################################################################
# Version: Commits on Jun 28, 2026
LIBRETRO_SQUIRRELJME_VERSION = ea7d142ed61d1258f46444b682db9796a671ad64
LIBRETRO_SQUIRRELJME_SITE = $(call github,SquirrelJME,SquirrelJME,$(LIBRETRO_SQUIRRELJME_VERSION))
LIBRETRO_SQUIRRELJME_LICENSE = MPL-2.0
LIBRETRO_SQUIRRELJME_LICENSE_FILES = LICENSE
LIBRETRO_SQUIRRELJME_DEPENDENCIES = retroarch
LIBRETRO_SQUIRRELJME_EMULATOR_INFO = squirreljme.libretro.core.yml

# The libretro core (NanoCoat, pure C99) lives in the nanocoat/ subtree.
LIBRETRO_SQUIRRELJME_SUBDIR = nanocoat
LIBRETRO_SQUIRRELJME_SUPPORTS_IN_SOURCE_BUILD = NO

LIBRETRO_SQUIRRELJME_CONF_OPTS += -DCMAKE_BUILD_TYPE=Release
LIBRETRO_SQUIRRELJME_CONF_OPTS += -DSQUIRRELJME_SPECIAL_BUILD_LIBRETRO=1
LIBRETRO_SQUIRRELJME_CONF_OPTS += -DSQUIRRELJME_BINARY_OUTPUT_ROOT=1

# Only build the libretro core target (skip tests/tools).
LIBRETRO_SQUIRRELJME_BUILD_OPTS = --target squirreljme_libretro

# With SQUIRRELJME_BINARY_OUTPUT_ROOT=1 the .so is emitted at the build root.
define LIBRETRO_SQUIRRELJME_INSTALL_TARGET_CMDS
	$(INSTALL) -D $(LIBRETRO_SQUIRRELJME_BUILDDIR)/squirreljme_libretro.so \
		$(TARGET_DIR)/usr/lib/libretro/squirreljme_libretro.so
endef

$(eval $(cmake-package))
$(eval $(emulator-info-package))
