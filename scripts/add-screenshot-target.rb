#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'xcodeproj'

PROJECT_PATH = File.expand_path('../ios-swift/Notelayer/Notelayer.xcodeproj', __dir__)
APP_TARGET_NAME = 'Notelayer'
TEST_TARGET_NAME = 'NotelayerScreenshotTests'
TESTS_GROUP_PATH = 'NotelayerScreenshotTests'
TEST_BUNDLE_IDENTIFIER = 'com.notelayer.app.NotelayerScreenshotTests'
DEPLOYMENT_TARGET = '16.0'
DEVELOPMENT_TEAM = 'DPVQ2X986Z'
SCHEME_NAME = 'Screenshot Generation'

project_path = ARGV[0] || PROJECT_PATH
pbxproj_path = File.join(project_path, 'project.pbxproj')

unless File.exist?(pbxproj_path)
  abort("Project file not found at #{pbxproj_path}")
end

project = Xcodeproj::Project.open(project_path)
app_target = project.targets.find { |target| target.name == APP_TARGET_NAME }

unless app_target
  abort("App target '#{APP_TARGET_NAME}' not found in project.")
end

test_target = project.targets.find { |target| target.name == TEST_TARGET_NAME }

if test_target.nil?
  test_target = project.new_target(:ui_test_bundle, TEST_TARGET_NAME, :ios, DEPLOYMENT_TARGET, app_target)
end

unless test_target.dependencies.any? { |dependency| dependency.target == app_target }
  test_target.add_dependency(app_target)
end

products_group = project.products_group
if products_group && test_target.product_reference && !products_group.files.include?(test_target.product_reference)
  products_group << test_target.product_reference
end

tests_group = project.main_group.find_subpath(TESTS_GROUP_PATH, true)
tests_group.set_source_tree('<group>')
tests_group.path = TESTS_GROUP_PATH

test_file_ref = tests_group.files.find { |file| file.path == 'ScreenshotGenerationTests.swift' }
test_file_ref ||= tests_group.new_file('ScreenshotGenerationTests.swift')

plist_file_ref = tests_group.files.find { |file| file.path == 'Info.plist' }
plist_file_ref ||= tests_group.new_file('Info.plist')

source_build_phase = test_target.source_build_phase
existing_sources = source_build_phase.files.map(&:file_ref)
unless existing_sources.include?(test_file_ref)
  source_build_phase.add_file_reference(test_file_ref, true)
end

test_target.build_configurations.each do |config|
  settings = config.build_settings
  settings['CODE_SIGN_STYLE'] = 'Automatic'
  settings['DEVELOPMENT_TEAM'] = DEVELOPMENT_TEAM
  settings['INFOPLIST_FILE'] = File.join(TESTS_GROUP_PATH, 'Info.plist')
  settings['IPHONEOS_DEPLOYMENT_TARGET'] = DEPLOYMENT_TARGET
  settings['LD_RUNPATH_SEARCH_PATHS'] = ['$(inherited)', '@executable_path/Frameworks', '@loader_path/Frameworks']
  settings['PRODUCT_BUNDLE_IDENTIFIER'] = TEST_BUNDLE_IDENTIFIER
  settings['PRODUCT_NAME'] = '$(TARGET_NAME)'
  settings['SDKROOT'] = 'iphoneos'
  settings['SWIFT_EMIT_LOC_STRINGS'] = 'NO'
  settings['SWIFT_VERSION'] = '5.0'
  settings['TARGETED_DEVICE_FAMILY'] = '1,2'
  settings['TEST_TARGET_NAME'] = APP_TARGET_NAME
end

project.save

scheme_dir = File.join(project_path, 'xcshareddata', 'xcschemes')
FileUtils.mkdir_p(scheme_dir)
scheme_path = File.join(scheme_dir, "#{SCHEME_NAME}.xcscheme")

app_product_name = app_target.product_reference&.path || "#{APP_TARGET_NAME}.app"
test_product_name = test_target.product_reference&.path || "#{TEST_TARGET_NAME}.xctest"

scheme_xml = <<~XML
  <?xml version="1.0" encoding="UTF-8"?>
  <Scheme
     LastUpgradeVersion = "2620"
     version = "1.7">
     <BuildAction
        parallelizeBuildables = "YES"
        buildImplicitDependencies = "YES"
        buildArchitectures = "Automatic">
        <BuildActionEntries>
           <BuildActionEntry
              buildForTesting = "YES"
              buildForRunning = "YES"
              buildForProfiling = "YES"
              buildForArchiving = "YES"
              buildForAnalyzing = "YES">
              <BuildableReference
                 BuildableIdentifier = "primary"
                 BlueprintIdentifier = "#{app_target.uuid}"
                 BuildableName = "#{app_product_name}"
                 BlueprintName = "#{app_target.name}"
                 ReferencedContainer = "container:Notelayer.xcodeproj">
              </BuildableReference>
           </BuildActionEntry>
        </BuildActionEntries>
     </BuildAction>
     <TestAction
        buildConfiguration = "Debug"
        selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
        selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
        shouldUseLaunchSchemeArgsEnv = "YES"
        shouldAutocreateTestPlan = "YES">
        <Testables>
           <TestableReference
              skipped = "NO">
              <BuildableReference
                 BuildableIdentifier = "primary"
                 BlueprintIdentifier = "#{test_target.uuid}"
                 BuildableName = "#{test_product_name}"
                 BlueprintName = "#{test_target.name}"
                 ReferencedContainer = "container:Notelayer.xcodeproj">
              </BuildableReference>
           </TestableReference>
        </Testables>
        <CommandLineArguments>
           <CommandLineArgument
              argument = "--screenshot-generation"
              isEnabled = "YES">
           </CommandLineArgument>
        </CommandLineArguments>
        <EnvironmentVariables>
           <EnvironmentVariable
              key = "SCREENSHOT_MODE"
              value = "true"
              isEnabled = "YES">
           </EnvironmentVariable>
        </EnvironmentVariables>
        <MacroExpansion>
           <BuildableReference
              BuildableIdentifier = "primary"
              BlueprintIdentifier = "#{app_target.uuid}"
              BuildableName = "#{app_product_name}"
              BlueprintName = "#{app_target.name}"
              ReferencedContainer = "container:Notelayer.xcodeproj">
           </BuildableReference>
        </MacroExpansion>
     </TestAction>
     <LaunchAction
        buildConfiguration = "Debug"
        selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
        selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
        launchStyle = "0"
        useCustomWorkingDirectory = "NO"
        ignoresPersistentStateOnLaunch = "NO"
        debugDocumentVersioning = "YES"
        debugServiceExtension = "internal"
        allowLocationSimulation = "YES">
        <BuildableProductRunnable
           runnableDebuggingMode = "0">
           <BuildableReference
              BuildableIdentifier = "primary"
              BlueprintIdentifier = "#{app_target.uuid}"
              BuildableName = "#{app_product_name}"
              BlueprintName = "#{app_target.name}"
              ReferencedContainer = "container:Notelayer.xcodeproj">
           </BuildableReference>
        </BuildableProductRunnable>
        <CommandLineArguments>
           <CommandLineArgument
              argument = "--screenshot-generation"
              isEnabled = "YES">
           </CommandLineArgument>
        </CommandLineArguments>
        <EnvironmentVariables>
           <EnvironmentVariable
              key = "SCREENSHOT_MODE"
              value = "true"
              isEnabled = "YES">
           </EnvironmentVariable>
        </EnvironmentVariables>
     </LaunchAction>
     <ProfileAction
        buildConfiguration = "Release"
        shouldUseLaunchSchemeArgsEnv = "YES"
        savedToolIdentifier = ""
        useCustomWorkingDirectory = "NO"
        debugDocumentVersioning = "YES">
        <BuildableProductRunnable
           runnableDebuggingMode = "0">
           <BuildableReference
              BuildableIdentifier = "primary"
              BlueprintIdentifier = "#{app_target.uuid}"
              BuildableName = "#{app_product_name}"
              BlueprintName = "#{app_target.name}"
              ReferencedContainer = "container:Notelayer.xcodeproj">
           </BuildableReference>
        </BuildableProductRunnable>
     </ProfileAction>
     <AnalyzeAction
        buildConfiguration = "Debug">
     </AnalyzeAction>
     <ArchiveAction
        buildConfiguration = "Release"
        revealArchiveInOrganizer = "YES">
     </ArchiveAction>
  </Scheme>
XML

File.write(scheme_path, scheme_xml)

puts "Updated #{TEST_TARGET_NAME} target and #{SCHEME_NAME} scheme."
