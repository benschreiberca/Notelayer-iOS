#!/usr/bin/env ruby
# add_platform_targets.rb
#
# Adds NotelayerMac (macOS menu bar) and NotelayerWatch (watchOS) targets
# to the existing Xcode project using the xcodeproj gem.
#
# Usage:
#   ruby scripts/add_platform_targets.rb
#
# Prerequisites:
#   gem install xcodeproj   (already installed at /usr/local/bin/xcodeproj)

require 'xcodeproj'
require 'fileutils'

REPO_ROOT    = File.expand_path('..', __dir__)
PROJECT_PATH = File.join(REPO_ROOT, 'ios-swift', 'Notelayer', 'Notelayer.xcodeproj')
MAC_SOURCES  = File.join(REPO_ROOT, 'ios-swift', 'Notelayer', 'NotelayerMac')
WATCH_SOURCES= File.join(REPO_ROOT, 'ios-swift', 'Notelayer', 'NotelayerWatch')
CORE_PKG     = File.join(REPO_ROOT, 'ios-swift', 'NotelayerCore')

puts "Opening project: #{PROJECT_PATH}"
project = Xcodeproj::Project.open(PROJECT_PATH)

# ─────────────────────────────────────────────
# Helper: ensure group exists at path
# ─────────────────────────────────────────────
def ensure_group(parent_group, name)
  parent_group[name] || parent_group.new_group(name)
end

# ─────────────────────────────────────────────
# Helper: add all .swift files in a directory to a target
# ─────────────────────────────────────────────
def add_swift_files(project, group, dir, target, relative_to: nil)
  Dir.glob(File.join(dir, '**', '*.swift')).sort.each do |path|
    rel = relative_to ? path.sub(relative_to + '/', '') : File.basename(path)
    parts = rel.split('/')
    current_group = group
    parts[0..-2].each do |part|
      current_group = ensure_group(current_group, part)
    end
    file_ref = current_group.new_file(path)
    target.add_file_references([file_ref])
  end
end

# ─────────────────────────────────────────────
# Helper: add a plist / entitlements resource
# ─────────────────────────────────────────────
def add_resource(group, path)
  group.new_file(path)
end

# ─────────────────────────────────────────────
# Check if targets already exist
# ─────────────────────────────────────────────
existing_names = project.targets.map(&:name)
puts "Existing targets: #{existing_names.join(', ')}"

# ═══════════════════════════════════════════════
# 1. NotelayerMac — macOS menu bar app
# ═══════════════════════════════════════════════
unless existing_names.include?('NotelayerMac')
  puts "\n▸ Adding NotelayerMac target..."

  mac_target = project.new_target(
    :application,
    'NotelayerMac',
    :osx,
    '14.0',
    project.products_group,
    :swift
  )

  # Build settings
  mac_target.build_configurations.each do |config|
    settings = config.build_settings
    settings['PRODUCT_BUNDLE_IDENTIFIER']     = 'com.notelayer.app.mac'
    settings['SWIFT_VERSION']                 = '5.9'
    settings['MACOSX_DEPLOYMENT_TARGET']      = '14.0'
    settings['INFOPLIST_FILE']                = 'NotelayerMac/Info.plist'
    settings['CODE_SIGN_ENTITLEMENTS']        = 'NotelayerMac/NotelayerMac.entitlements'
    settings['ENABLE_HARDENED_RUNTIME']       = 'YES'
    settings['CODE_SIGN_STYLE']               = 'Automatic'
    settings['DEVELOPMENT_TEAM']              = ''  # Set in Xcode
    settings['ASSETCATALOG_COMPILER_APPICON_NAME'] = 'AppIcon'
    settings['PRODUCT_NAME']                  = 'Notelayer'
    settings['SWIFT_OPTIMIZATION_LEVEL']      = config.name == 'Debug' ? '-Onone' : '-O'
    settings['DEBUG_INFORMATION_FORMAT']      = config.name == 'Debug' ? 'dwarf' : 'dwarf-with-dsym'
  end

  # Source group
  mac_group = ensure_group(project.main_group, 'NotelayerMac')
  add_swift_files(project, mac_group, MAC_SOURCES, mac_target,
                  relative_to: MAC_SOURCES)

  # Info.plist and entitlements as references (not compiled)
  mac_group.new_file(File.join(MAC_SOURCES, 'Info.plist'))
  mac_group.new_file(File.join(MAC_SOURCES, 'NotelayerMac.entitlements'))

  puts "  ✓ NotelayerMac target created"
else
  puts "  ⚠ NotelayerMac target already exists — skipping"
end

# ═══════════════════════════════════════════════
# 2. NotelayerWatch — watchOS app
# ═══════════════════════════════════════════════
unless existing_names.include?('NotelayerWatch')
  puts "\n▸ Adding NotelayerWatch target..."

  watch_target = project.new_target(
    :application,
    'NotelayerWatch',
    :watchos,
    '7.0',
    project.products_group,
    :swift
  )

  watch_target.build_configurations.each do |config|
    settings = config.build_settings
    settings['PRODUCT_BUNDLE_IDENTIFIER']     = 'com.notelayer.app.watch'
    settings['SWIFT_VERSION']                 = '5.9'
    settings['WATCHOS_DEPLOYMENT_TARGET']     = '7.0'
    settings['INFOPLIST_FILE']                = 'NotelayerWatch/Info.plist'
    settings['CODE_SIGN_STYLE']               = 'Automatic'
    settings['DEVELOPMENT_TEAM']              = ''  # Set in Xcode
    settings['ASSETCATALOG_COMPILER_APPICON_NAME'] = 'AppIcon'
    settings['PRODUCT_NAME']                  = 'Notelayer Watch'
    settings['SWIFT_OPTIMIZATION_LEVEL']      = config.name == 'Debug' ? '-Onone' : '-O'
    settings['DEBUG_INFORMATION_FORMAT']      = config.name == 'Debug' ? 'dwarf' : 'dwarf-with-dsym'
    # Watch apps require WKApplication key — already in Info.plist
    settings['GENERATE_INFOPLIST_FILE']       = 'NO'
  end

  # Source group
  watch_group = ensure_group(project.main_group, 'NotelayerWatch')
  add_swift_files(project, watch_group, WATCH_SOURCES, watch_target,
                  relative_to: WATCH_SOURCES)
  watch_group.new_file(File.join(WATCH_SOURCES, 'Info.plist'))

  puts "  ✓ NotelayerWatch target created"
else
  puts "  ⚠ NotelayerWatch target already exists — skipping"
end

# ═══════════════════════════════════════════════
# 3. NotelayerCore — local Swift package reference
# ═══════════════════════════════════════════════
# Swift packages are referenced via XCLocalSwiftPackageReference.
# The xcodeproj gem supports this via the remote package API.
# For local packages, we add a file reference to the Package.swift.
unless project.main_group['NotelayerCore']
  puts "\n▸ Adding NotelayerCore package reference..."
  core_group = project.main_group.new_group('NotelayerCore', CORE_PKG)
  core_group.new_file(File.join(CORE_PKG, 'Package.swift'))
  puts "  ✓ NotelayerCore group added"
  puts "  ℹ  To link NotelayerCore to targets: File > Add Package Dependencies > Add Local in Xcode"
end

# ─────────────────────────────────────────────
# Save
# ─────────────────────────────────────────────
project.save
puts "\n✅ Project saved: #{PROJECT_PATH}"
puts "\nNext steps in Xcode:"
puts "  1. Open Notelayer.xcworkspace (not .xcodeproj)"
puts "  2. Select NotelayerMac target → General → set Team"
puts "  3. Select NotelayerWatch target → General → set Team"
puts "  4. File > Add Package Dependencies > Add Local → select ios-swift/NotelayerCore"
puts "  5. Link NotelayerCore to both NotelayerMac and NotelayerWatch targets"
puts "  6. Build each target (⌘B) and address any remaining signing issues"
