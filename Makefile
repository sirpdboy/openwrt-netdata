#
# Copyright (C) 2008-2023 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=netdata
PKG_VERSION:=1.37.1
PKG_RELEASE:=local

PKG_MAINTAINER:=M. Raymond Vaughn <nethershaw@gmail.com>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:my-netdata:netdata

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/netdata/netdata.git
PKG_SOURCE_VERSION:=v${PKG_VERSION}
PKG_SOURCE_DATE=2022-12-05
PKG_MIRROR_HASH:=c57ae7f5334b740a2c505c9a06705c40b92dec6e5f8b98977ed748e749dabd01

HOST_FIXUP:=autoreconf

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf
PKG_USE_MIPS16:=0

include $(INCLUDE_DIR)/package.mk

define Package/netdata/Default
	SECTION:=admin
	CATEGORY:=Administration
	DEPENDS:=+zlib +libuuid +libuv +libmnl +libjson-c +bash +coreutils-timeout +curl +uuidgen +liblz4 +libcap +openssl-util +libatomic +libstdcpp +libc +libcups
	TITLE:=Real-time performance monitoring tool
	URL:=https://www.netdata.cloud/
endef

define Package/netdata
	$(call Package/netdata/Default)
endef

define Package/netdata/description
  netdata is a highly optimized Linux daemon providing real-time performance
  monitoring for Linux systems, applications and SNMP devices over the web.
endef

TARGET_CFLAGS := $(filter-out -O%,$(TARGET_CFLAGS))
ifeq ($(CONFIG_DEBUG),y)
	TARGET_CFLAGS := -O1 -ggdb3 -DNETDATA_INTERNAL_CHECKS=1 -DNETDATA_DEV_MODE=1 -fstack-protector-all -fno-omit-frame-pointer
else
	TARGET_CFLAGS += -O2
endif
TARGET_LDFLAGS += -Wl,--gc-sections

CONFIGURE_ARGS += \
	--disable-cloud \
	--disable-ebpf

define Package/netdata/conffiles
	/etc/netdata/
endef

define Package/netdata/install
	$(INSTALL_DIR) $(1)/etc/netdata/custom-plugins.d
	$(CP) $(PKG_INSTALL_DIR)/etc/netdata $(1)/etc
	$(CP) ./files/netdata.conf $(1)/etc/netdata
	touch $(1)/etc/netdata/.opt-out-from-anonymous-statistics
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/netdata $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/netdata $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/netdatacli $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/netdata-claim.sh $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/usr/share/netdata
	$(CP) $(PKG_INSTALL_DIR)/usr/share/netdata $(1)/usr/share
	rm $(1)/usr/share/netdata/web/demo*html
	rm $(1)/usr/share/netdata/web/fonts/*.svg
	rm $(1)/usr/share/netdata/web/fonts/*.ttf
	rm $(1)/usr/share/netdata/web/fonts/*.woff
	rm $(1)/usr/share/netdata/web/images/*.png
	rm $(1)/usr/share/netdata/web/images/*.gif
	rm $(1)/usr/share/netdata/web/images/*.ico
	rm -rf $(1)/usr/share/netdata/web/old
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/netdata.init $(1)/etc/init.d/netdata
endef

$(eval $(call BuildPackage,netdata))
