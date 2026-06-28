################################################################################
#
# libretro-freej2me
#
################################################################################
# Version: Commits on Jun 10, 2026 (devel)
LIBRETRO_FREEJ2ME_VERSION = 0c625ac084384d8932f82a35e0a13b6bf70e0ed0
LIBRETRO_FREEJ2ME_SITE = $(call github,TASEmulators,freej2me-plus,$(LIBRETRO_FREEJ2ME_VERSION))
LIBRETRO_FREEJ2ME_LICENSE = GPL-3.0, BSD-3-Clause (ObjectWeb ASM), LGPL-2.1 (JLayer), MIT, Zlib
LIBRETRO_FREEJ2ME_LICENSE_FILES = LICENSE
# retroarch        : libretro frontend
# openjdk          : the "java" runtime invoked by the core at runtime (target)
# host-openjdk-bin : javac/jar used to build freej2me-lr.jar at build time
LIBRETRO_FREEJ2ME_DEPENDENCIES = retroarch openjdk host-openjdk-bin
LIBRETRO_FREEJ2ME_EMULATOR_INFO = freej2me.libretro.core.yml

LIBRETRO_FREEJ2ME_PLATFORM = $(LIBRETRO_PLATFORM)

# host-openjdk-bin installs the JDK under $(HOST_DIR)/lib/jvm
LIBRETRO_FREEJ2ME_JAVA_BIN = $(HOST_DIR)/lib/jvm/bin

# Replicate build.xml using the host JDK (buildroot has no apache-ant):
#  1. compile ObjectWeb ASM sources
#  2. compile FreeJ2ME (AWT + Libretro), excluding ObjectWeb sources
#  3. stage classes + resources + META-INF, then package freej2me-lr.jar
#     (Main-Class org.recompile.freej2me.Libretro)
# The upstream build.xml pins source/target 1.6 with a JDK8 bootclasspath; we
# use "--release 8" instead, which works with the modern host-openjdk (17/21).
define LIBRETRO_FREEJ2ME_BUILD_JAR
	rm -rf $(@D)/build/classes $(@D)/build/jarstage
	mkdir -p $(@D)/build/classes $(@D)/build/jarstage
	cd $(@D) && $(LIBRETRO_FREEJ2ME_JAVA_BIN)/javac -nowarn -encoding utf-8 \
		--release 8 -implicit:none \
		-d build/classes -sourcepath src \
		$$(find src/org/objectweb/asm -name '*.java')
	cd $(@D) && $(LIBRETRO_FREEJ2ME_JAVA_BIN)/javac -encoding utf-8 \
		--release 8 \
		-classpath build/classes \
		-d build/classes -sourcepath src \
		$$(find src -name '*.java' -not -path 'src/org/objectweb/*' \
			-not -path 'src/libretro/*')
	cp -a $(@D)/build/classes/. $(@D)/build/jarstage/
	test -d $(@D)/resources && cp -a $(@D)/resources/. $(@D)/build/jarstage/ || true
	test -d $(@D)/META-INF && cp -a $(@D)/META-INF $(@D)/build/jarstage/ || true
	cd $(@D)/build/jarstage && $(LIBRETRO_FREEJ2ME_JAVA_BIN)/jar cfe \
		$(@D)/build/freej2me-lr.jar org.recompile.freej2me.Libretro .
endef

# Build the libretro C core (thin shim that spawns the JVM).
define LIBRETRO_FREEJ2ME_BUILD_CORE
	$(TARGET_CONFIGURE_OPTS) $(MAKE) CXX="$(TARGET_CXX)" CC="$(TARGET_CC)" \
		-C $(@D)/src/libretro/ platform="$(LIBRETRO_FREEJ2ME_PLATFORM)"
endef

define LIBRETRO_FREEJ2ME_BUILD_CMDS
	$(LIBRETRO_FREEJ2ME_BUILD_JAR)
	$(LIBRETRO_FREEJ2ME_BUILD_CORE)
endef

# freej2me_libretro.so -> libretro cores dir
# freej2me-lr.jar      -> BIOS (libretro system_directory = /userdata/bios/)
define LIBRETRO_FREEJ2ME_INSTALL_TARGET_CMDS
	$(INSTALL) -D $(@D)/src/libretro/freej2me_libretro.so \
		$(TARGET_DIR)/usr/lib/libretro/freej2me_libretro.so
	$(INSTALL) -D -m 0644 $(@D)/build/freej2me-lr.jar \
		$(TARGET_DIR)/usr/share/batocera/datainit/bios/freej2me-lr.jar
endef

$(eval $(generic-package))
$(eval $(emulator-info-package))
