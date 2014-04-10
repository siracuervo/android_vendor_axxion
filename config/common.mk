PRODUCT_BRAND ?= AxxionKat

SUPERUSER_EMBEDDED := true
SUPERUSER_PACKAGE_PREFIX := com.android.settings.cyanogenmod.superuser

ifneq ($(TARGET_SCREEN_WIDTH) $(TARGET_SCREEN_HEIGHT),$(space))
# determine the smaller dimension
TARGET_BOOTANIMATION_SIZE := $(shell \
  if [ $(TARGET_SCREEN_WIDTH) -lt $(TARGET_SCREEN_HEIGHT) ]; then \
    echo $(TARGET_SCREEN_WIDTH); \
  else \
    echo $(TARGET_SCREEN_HEIGHT); \
  fi )

# get a sorted list of the sizes
bootanimation_sizes := $(subst .zip,, $(shell ls vendor/axxion/prebuilt/common/bootanimation))
bootanimation_sizes := $(shell echo -e $(subst $(space),'\n',$(bootanimation_sizes)) | sort -rn)

# find the appropriate size and set
define check_and_set_bootanimation
$(eval TARGET_BOOTANIMATION_NAME := $(shell \
  if [ -z "$(TARGET_BOOTANIMATION_NAME)" ]; then
    if [ $(1) -le $(TARGET_BOOTANIMATION_SIZE) ]; then \
      echo $(1); \
      exit 0; \
    fi;
  fi;
  echo $(TARGET_BOOTANIMATION_NAME); ))
endef
$(foreach size,$(bootanimation_sizes), $(call check_and_set_bootanimation,$(size)))

ifeq ($(TARGET_BOOTANIMATION_HALF_RES),true)
PRODUCT_BOOTANIMATION := vendor/axxion/prebuilt/common/bootanimation/halfres/$(TARGET_BOOTANIMATION_NAME).zip
else
PRODUCT_BOOTANIMATION := vendor/axxion/prebuilt/common/bootanimation/$(TARGET_BOOTANIMATION_NAME).zip
endif
endif

ifdef axxion_NIGHTLY
PRODUCT_PROPERTY_OVERRIDES += \
    ro.rommanager.developerid=cyanogenmodnightly
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.rommanager.developerid=cyanogenmod
endif

PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0

ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=android-google
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

PRODUCT_PROPERTY_OVERRIDES += \
    keyguard.no_require_sim=true \
    ro.url.legal=http://www.google.com/intl/%s/mobile/android/basic/phone-legal.html \
    ro.url.legal.android_privacy=http://www.google.com/intl/%s/mobile/android/basic/privacy.html \
    ro.com.android.wifi-watchlist=GoogleGuest \
    ro.setupwizard.enterprise_mode=1 \
    ro.com.android.dateformat=MM-dd-yyyy \
    ro.com.android.dataroaming=false

PRODUCT_PROPERTY_OVERRIDES += \
    ro.build.selinux=1

# Thank you, please drive thru!
PRODUCT_PROPERTY_OVERRIDES += persist.sys.dun.override=0

ifneq ($(TARGET_BUILD_VARIANT),eng)
# Enable ADB authentication
ADDITIONAL_DEFAULT_PROPERTIES += ro.adb.secure=3
endif

# Copy over the changelog to the device
PRODUCT_COPY_FILES += \
    vendor/axxion/CHANGELOG.mkdn:system/etc/CHANGELOG-axxion.txt

# Backup Tool
ifneq ($(WITH_GMS),true)
PRODUCT_COPY_FILES += \
    vendor/axxion/prebuilt/common/bin/backuptool.sh:system/bin/backuptool.sh \
    vendor/axxion/prebuilt/common/bin/backuptool.functions:system/bin/backuptool.functions \
    vendor/axxion/prebuilt/common/bin/50-axxion.sh:system/addon.d/50-axxion.sh \
    vendor/axxion/prebuilt/common/bin/blacklist:system/addon.d/blacklist
endif

# init.d support
PRODUCT_COPY_FILES += \
    vendor/axxion/prebuilt/common/etc/init.d/00banner:system/etc/init.d/00banner \
    vendor/axxion/prebuilt/common/bin/sysinit:system/bin/sysinit

# userinit support
PRODUCT_COPY_FILES += \
    vendor/axxion/prebuilt/common/etc/init.d/90userinit:system/etc/init.d/90userinit

# axxion-specific init file
PRODUCT_COPY_FILES += \
    vendor/axxion/prebuilt/common/etc/init.local.rc:root/init.axxion.rc

# Bring in camera effects
PRODUCT_COPY_FILES +=  \
    vendor/axxion/prebuilt/common/media/LMprec_508.emd:system/media/LMprec_508.emd \
    vendor/axxion/prebuilt/common/media/PFFprec_600.emd:system/media/PFFprec_600.emd

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml

# Enable wireless Xbox 360 controller support
PRODUCT_COPY_FILES += \
    frameworks/base/data/keyboards/Vendor_045e_Product_028e.kl:system/usr/keylayout/Vendor_045e_Product_0719.kl

# This is axxion!
PRODUCT_COPY_FILES += \
    vendor/axxion/config/permissions/com.cyanogenmod.android.xml:system/etc/permissions/com.cyanogenmod.android.xml

# T-Mobile theme engine
include vendor/axxion/config/themes_common.mk

# Required axxion packages
PRODUCT_PACKAGES += \
    Development \
    LatinIME \
    BluetoothExt

# Optional axxion packages
PRODUCT_PACKAGES += \
    VoicePlus \
    Basic \
    libemoji

# Custom axxion packages
PRODUCT_PACKAGES += \
    Launcher3 \
    Trebuchet \
    DSPManager \
    libcyanogen-dsp \
    audio_effects.conf \
    CMWallpapers \
    Apollo \
    CMFileManager \
    LockClock \
    CMFota

# axxion Hardware Abstraction Framework
PRODUCT_PACKAGES += \
    org.cyanogenmod.hardware \
    org.cyanogenmod.hardware.xml

# Extra tools in axxion
PRODUCT_PACKAGES += \
    libsepol \
    openvpn \
    e2fsck \
    mke2fs \
    tune2fs \
    bash \
    nano \
    htop \
    powertop \
    lsof \
    mount.exfat \
    fsck.exfat \
    mkfs.exfat \
    ntfsfix \
    ntfs-3g \
    gdbserver \
    micro_bench \
    oprofiled \
    sqlite3 \
    strace

# Openssh
PRODUCT_PACKAGES += \
    scp \
    sftp \
    ssh \
    sshd \
    sshd_config \
    ssh-keygen \
    start-ssh

# rsync
PRODUCT_PACKAGES += \
    rsync

# These packages are excluded from user builds
ifneq ($(TARGET_BUILD_VARIANT),user)

PRODUCT_PACKAGES += \
    procmem \
    procrank \
    Superuser \
    su

# Terminal Emulator
PRODUCT_COPY_FILES +=  \
    vendor/axxion/proprietary/Term.apk:system/app/Term.apk \
    vendor/axxion/proprietary/lib/armeabi/libjackpal-androidterm4.so:system/lib/libjackpal-androidterm4.so

PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.root_access=1
else

PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.root_access=0

endif

# easy way to extend to add more packages
-include vendor/extra/product.mk

PRODUCT_PACKAGE_OVERLAYS += vendor/axxion/overlay/common

# version
RELEASE = false
AXXION_VERSION_MAJOR = 1.0
AXXION_VERSION_MINOR = 0

# release
ifeq ($(RELEASE),true)
    AXXION_VERSION_STATE := OFFICIAL
    AXXION_VERSION := AxxionKat-v$(AXXION_VERSION_MAJOR).$(AXXION_VERSION_MINOR)-$(AXXION_VERSION_STATE)
else
    AXXION_VERSION_STATE := $(shell date +%Y-%m-%d)
    AXXION_VERSION := AxxionKat-v$(AXXION_VERSION_MAJOR).$(AXXION_VERSION_MINOR)-$(AXXION_VERSION_STATE)
endif

PRODUCT_PROPERTY_OVERRIDES += \
  ro.axxion.version=$(AXXION_VERSION) \
  ro.modversion=$(AXXION_VERSION) \
  ro.cmlegal.url=http://www.cyanogenmod.org/docs/privacy

-include vendor/axxion-priv/keys/keys.mk

AXXION_DISPLAY_VERSION := $(AXXION_VERSION)

ifneq ($(AXXION_DEFAULT_DEV_CERTIFICATE),)
ifneq ($(AXXION_DEFAULT_DEV_CERTIFICATE),build/target/product/security/testkey)
  ifneq ($(AXXION_BUILDTYPE), UNOFFICIAL)
    ifndef TARGET_VENDOR_RELEASE_BUILD_ID
 ifneq ($(AXXION_EXTRAVERSION),)
        TARGET_VENDOR_RELEASE_BUILD_ID := $(AXXION_EXTRAVERSION)
else
        TARGET_VENDOR_RELEASE_BUILD_ID := -$(shell date -u +%Y%m%d)
endif
else
      TARGET_VENDOR_RELEASE_BUILD_ID := -$(TARGET_VENDOR_RELEASE_BUILD_ID)
endif
    AXXION_DISPLAY_VERSION=$(AXXION_VERSION_MAJOR).$(AXXION_VERSION_MINOR)$(TARGET_VENDOR_RELEASE_BUILD_ID)
endif
endif
endif

PRODUCT_PROPERTY_OVERRIDES += \
  ro.axxion.display.version=$(AxxionKat_DISPLAY_VERSION)

-include $(WORKSPACE)/build_env/image-auto-bits.mk

-include vendor/cyngn/product.mk
