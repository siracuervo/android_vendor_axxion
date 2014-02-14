# Inherit common axxion stuff
$(call inherit-product, vendor/axxion/config/common.mk)

# Include axxion audio files
include vendor/axxion/config/axxion_audio.mk

# Default notification/alarm sounds
PRODUCT_PROPERTY_OVERRIDES += \
    ro.config.notification_sound=Argon.ogg \
    ro.config.alarm_alert=Hassium.ogg

ifeq ($(TARGET_SCREEN_WIDTH) $(TARGET_SCREEN_HEIGHT),$(space))
    PRODUCT_COPY_FILES += \
        vendor/axxion/prebuilt/common/bootanimation/800.zip:system/media/bootanimation.zip
endif
