#!/bin/bash

# Configuration
APP_NAME="Prime Invoice"
APP_PATH="build/macos/Build/Products/Release/${APP_NAME}.app"
DMG_NAME="PrimeInvoice_v1.0.1.dmg"
STAGING_DIR="build/macos/dmg_staging"

echo "Creating DMG for ${APP_NAME}..."

# Remove old staging dir and DMG
rm -rf "${STAGING_DIR}"
rm -f "${DMG_NAME}"

# Create staging directory
mkdir -p "${STAGING_DIR}"

# Copy the app to the staging directory
echo "Copying ${APP_NAME}.app to staging..."
cp -R "${APP_PATH}" "${STAGING_DIR}/"

# Create a symlink to /Applications
echo "Creating /Applications symlink..."
ln -s /Applications "${STAGING_DIR}/Applications"

# Create the DMG
echo "Generating DMG..."
hdiutil create -volname "${APP_NAME}" -srcfolder "${STAGING_DIR}" -ov -format UDZO "${DMG_NAME}"

echo "Cleaning up..."
rm -rf "${STAGING_DIR}"

echo "DMG created: ${DMG_NAME}"
