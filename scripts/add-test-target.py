#!/usr/bin/env python3
"""
Script to add UI Test Target to Xcode project for screenshot generation.
This script modifies the project.pbxproj file to add the NotelayerScreenshotTests target.
"""

import re
import uuid
import sys
import os

def generate_id():
    """Generate a 24-character hex ID for Xcode project objects"""
    return ''.join([format(ord(c), '02X')[:2] for c in uuid.uuid4().hex[:12]]).upper()

def add_test_target(project_path):
    """Add UI Test Target to Xcode project"""
    
    with open(project_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Generate unique IDs for new objects
    test_target_id = generate_id()
    test_product_id = generate_id()
    test_build_config_debug_id = generate_id()
    test_build_config_release_id = generate_id()
    test_build_config_list_id = generate_id()
    test_sources_phase_id = generate_id()
    test_frameworks_phase_id = generate_id()
    test_resources_phase_id = generate_id()
    test_dependency_id = generate_id()
    
    # Add test product reference
    product_ref_match = r'(BC2CCDD62F174A5100406D9A /\* Notelayer\.app \*/ = \{isa = PBXFileReference.*?sourceTree = BUILT_PRODUCTS_DIR; \};)'
    product_ref_addition = f'\\1\n\t\t{test_product_id} /* NotelayerScreenshotTests.xctest */ = {{isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = NotelayerScreenshotTests.xctest; sourceTree = BUILT_PRODUCTS_DIR; }};'
    content = re.sub(product_ref_match, product_ref_addition, content, flags=re.DOTALL)
    
    # Add test product to Products group
    products_match = r'(BC2CCDD72F174A5100406D9A /\* Products \*/ = \{[^}]+children = \(\s+BC2CCDD62F174A5100406D9A /\* Notelayer\.app \*/,)'
    products_addition = f'\\1\n\t\t\t\t{test_product_id} /* NotelayerScreenshotTests.xctest */,'
    content = re.sub(products_match, products_addition, content)
    
    # Add test target to targets list
    targets_match = r'(targets = \(\s+BC2CCDD52F174A5100406D9A /\* Notelayer \*/,)'
    targets_addition = f'\\1\n\t\t\t\t{test_target_id} /* NotelayerScreenshotTests */,'
    content = re.sub(targets_match, targets_addition, content)
    
    # Add build phases
    build_phases_section = f'''/* Begin PBXSourcesBuildPhase section */
\t\t{test_sources_phase_id} /* Sources */ = {{
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXSourcesBuildPhase section */

/* Begin PBXFrameworksBuildPhase section */
\t\t{test_frameworks_phase_id} /* Frameworks */ = {{
\t\t\tisa = PBXFrameworksBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXResourcesBuildPhase section */
\t\t{test_resources_phase_id} /* Resources */ = {{
\t\t\tisa = PBXResourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXResourcesBuildPhase section */'''
    
    # Insert before XCBuildConfiguration section
    content = content.replace('/* Begin XCBuildConfiguration section */', 
                             build_phases_section + '\n\n/* Begin XCBuildConfiguration section */')
    
    # Add test target definition
    test_target_section = f'''\t\t{test_target_id} /* NotelayerScreenshotTests */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = {test_build_config_list_id} /* Build configuration list for PBXNativeTarget "NotelayerScreenshotTests" */;
\t\t\tbuildPhases = (
\t\t\t\t{test_sources_phase_id} /* Sources */,
\t\t\t\t{test_frameworks_phase_id} /* Frameworks */,
\t\t\t\t{test_resources_phase_id} /* Resources */,
\t\t\t);
\t\t\tbuildRules = (
\t\t\t);
\t\t\tdependencies = (
\t\t\t\t{test_dependency_id} /* PBXTargetDependency */,
\t\t\t);
\t\t\tname = NotelayerScreenshotTests;
\t\t\tproductName = NotelayerScreenshotTests;
\t\t\tproductReference = {test_product_id} /* NotelayerScreenshotTests.xctest */;
\t\t\tproductType = "com.apple.product-type.bundle.ui-testing";
\t\t}};'''
    
    content = content.replace('/* End PBXNativeTarget section */', 
                             test_target_section + '\n/* End PBXNativeTarget section */')
    
    # Add target dependency
    dependency_section = f'''\t\t{test_dependency_id} /* PBXTargetDependency */ = {{
\t\t\tisa = PBXTargetDependency;
\t\t\ttarget = BC2CCDD52F174A5100406D9A /* Notelayer */;
\t\t\ttargetProxy = {generate_id()} /* PBXContainerItemProxy */;
\t\t}};'''
    
    # Add dependency section (need to find where to insert)
    if '/* Begin PBXTargetDependency section */' not in content:
        content = content.replace('/* End PBXNativeTarget section */', 
                                 '/* End PBXNativeTarget section */\n\n/* Begin PBXTargetDependency section */\n' + 
                                 dependency_section + '\n/* End PBXTargetDependency section */')
    else:
        content = content.replace('/* End PBXTargetDependency section */', 
                                 dependency_section + '\n/* End PBXTargetDependency section */')
    
    # Add build configurations for test target
    test_debug_config = f'''\t\t{test_build_config_debug_id} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tDEVELOPMENT_TEAM = DPVQ2X986Z;
\t\t\t\tINFOPLIST_FILE = NotelayerScreenshotTests/Info.plist;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 16.0;
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t\t"@loader_path/Frameworks",
\t\t\t\t);
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.notelayer.app.NotelayerScreenshotTests;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = NO;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTEST_TARGET_NAME = Notelayer;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";
\t\t\t}};
\t\t\tname = Debug;
\t\t}};'''
    
    test_release_config = f'''\t\t{test_build_config_release_id} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tDEVELOPMENT_TEAM = DPVQ2X986Z;
\t\t\t\tINFOPLIST_FILE = NotelayerScreenshotTests/Info.plist;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 16.0;
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t\t"@loader_path/Frameworks",
\t\t\t\t);
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.notelayer.app.NotelayerScreenshotTests;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = NO;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTEST_TARGET_NAME = Notelayer;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";
\t\t\t}};
\t\t\tname = Release;
\t\t}};'''
    
    # Insert test build configs before the end of XCBuildConfiguration section
    content = content.replace('\t\tBC2CCDE32F174A5200406D9A /* Release */ = {', 
                             test_debug_config + '\n' + test_release_config + '\n\t\tBC2CCDE32F174A5200406D9A /* Release */ = {')
    
    # Add build configuration list for test target
    test_config_list = f'''\t\t{test_build_config_list_id} /* Build configuration list for PBXNativeTarget "NotelayerScreenshotTests" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{test_build_config_debug_id} /* Debug */,
\t\t\t\t{test_build_config_release_id} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};'''
    
    content = content.replace('/* End XCConfigurationList section */', 
                             test_config_list + '\n/* End XCConfigurationList section */')
    
    # Add target attributes
    target_attrs_match = r'(TargetAttributes = \{[^}]+BC2CCDD52F174A5100406D9A = \{([^}]+)\};)'
    target_attrs_addition = f'\\1\n\t\t\t\t\t{test_target_id} = {{\n\t\t\t\t\t\tCreatedOnToolsVersion = 26.2;\n\t\t\t\t\t\tTestTargetID = BC2CCDD52F174A5100406D9A;\n\t\t\t\t\t}};'
    content = re.sub(target_attrs_match, target_attrs_addition, content, flags=re.DOTALL)
    
    # Write back
    with open(project_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"✅ Successfully added NotelayerScreenshotTests target to project")
    print(f"⚠️  Note: You may need to open the project in Xcode to verify the target was added correctly")
    print(f"⚠️  You'll also need to create an Info.plist file for the test target")

if __name__ == '__main__':
    project_path = os.path.join(os.path.dirname(__file__), '..', 'ios-swift', 'Notelayer', 'Notelayer.xcodeproj', 'project.pbxproj')
    project_path = os.path.abspath(project_path)
    
    if not os.path.exists(project_path):
        print(f"❌ Error: Project file not found at {project_path}")
        sys.exit(1)
    
    try:
        add_test_target(project_path)
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
