//
//  Constants.swift
//  
//
//  Created by Stelios Petrakis on 14/4/24.
//

import Foundation

struct CliSyntaxColor {
    static let WHITE_BOLD = "\u{001B}[0;1m"
    static let RED = "\u{001B}[0;0;31m"
    static let GREEN = "\u{001B}[0;32m"
    static let YELLOW = "\u{001B}[0;33m"
    static let BLUE = "\u{001B}[0;34m"
    static let MAGENTA = "\u{001B}[0;35m"
    static let CYAN = "\u{001B}[0;36m"
    static let PINK = "\u{001B}[0;91m"
    static let GREEN_BRIGHT = "\u{001B}[0;92m"
    static let YELLOW_BRIGHT = "\u{001B}[0;93m"
    static let BLUE_BRIGHT = "\u{001B}[0;94m"
    static let MAGENTA_BRIGHT = "\u{001B}[0;95m"
    static let CYAN_BRIGHT = "\u{001B}[0;96m"
    static let END = "\u{001B}[0;0m"
}

enum RequiredReasonKey: CaseIterable {
    case FILE_TIMESTAMP_APIS_KEY
    case SYSTEM_BOOT_APIS_KEY
    case DISK_SPACE_APIS_KEY
    case ACTIVE_KEYBOARD_APIS_KEY
    case USER_DEFAULTS_APIS_KEY
    case CORELOCATION_FRAMEWORK_KEY
    case HEALTHKIT_FRAMEWORK_KEY
    case CRASH_FRAMEWORK_KEY
    case CONTACTS_FRAMEWORK_KEY
    
    var description: String {
        switch self {
        case .FILE_TIMESTAMP_APIS_KEY:
            return "File Timestamp APIs"
        case .SYSTEM_BOOT_APIS_KEY:
            return "System boot time APIs"
        case .DISK_SPACE_APIS_KEY:
            return "Disk space APIs"
        case .ACTIVE_KEYBOARD_APIS_KEY:
            return "Active keyboard APIs"
        case .USER_DEFAULTS_APIS_KEY:
            return "User defaults APIs"
        case .CORELOCATION_FRAMEWORK_KEY:
            return "Core Location"
        case .HEALTHKIT_FRAMEWORK_KEY:
            return "HealthKit"
        case .CRASH_FRAMEWORK_KEY:
            return "Crash data"
        case .CONTACTS_FRAMEWORK_KEY:
            return "Contacts"
        }
    }

    var link: String {
        switch self {
        case .FILE_TIMESTAMP_APIS_KEY:
            return "https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api#4278393"
        case .SYSTEM_BOOT_APIS_KEY:
            return "https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api#4278394"
        case .DISK_SPACE_APIS_KEY:
            return "https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api#4278397"
        case .ACTIVE_KEYBOARD_APIS_KEY:
            return "https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api#4278400"
        case .USER_DEFAULTS_APIS_KEY:
            return "https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api#4278401"
        case .CORELOCATION_FRAMEWORK_KEY:
            return "https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_data_use_in_privacy_manifests#4263133"
        case .HEALTHKIT_FRAMEWORK_KEY:
            return "https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_data_use_in_privacy_manifests#4263132"
        case .CRASH_FRAMEWORK_KEY:
            return "https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_data_use_in_privacy_manifests#4263159"
        case .CONTACTS_FRAMEWORK_KEY:
            return "https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_data_use_in_privacy_manifests#4263130"
        }
    }
}

let ALLOWED_EXTENSIONS = [
    "m",    // Objective-C
    "mm",   // Objective-C++
    "c",    // C
    "cpp",  // C++
    "swift" // Swift
]

// Look through the code for the listed strings (Case Sensitive)
let APIS_TO_CHECK: [String: [RequiredReasonKey]] = [
    // Ref: https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api

    "creationDate": [.FILE_TIMESTAMP_APIS_KEY],
    "modificationDate": [.FILE_TIMESTAMP_APIS_KEY],
    "fileModificationDate": [.FILE_TIMESTAMP_APIS_KEY],
    "contentModificationDateKey": [.FILE_TIMESTAMP_APIS_KEY],
    "creationDateKey": [.FILE_TIMESTAMP_APIS_KEY],
    "getattrlist(": [.FILE_TIMESTAMP_APIS_KEY, .DISK_SPACE_APIS_KEY], // also covers: fgetattrlist(
    "getattrlistbulk(": [.FILE_TIMESTAMP_APIS_KEY],
    "fstat(": [.FILE_TIMESTAMP_APIS_KEY],
    "fstatat(": [.FILE_TIMESTAMP_APIS_KEY],
    "lstat(": [.FILE_TIMESTAMP_APIS_KEY],
    "getattrlistat(": [.FILE_TIMESTAMP_APIS_KEY, .DISK_SPACE_APIS_KEY],
    "systemUptime": [.SYSTEM_BOOT_APIS_KEY],
    "mach_absolute_time(": [.SYSTEM_BOOT_APIS_KEY],

    "volumeAvailableCapacityKey": [.DISK_SPACE_APIS_KEY],
    "volumeAvailableCapacityForImportantUsageKey": [.DISK_SPACE_APIS_KEY],
    "volumeAvailableCapacityForOpportunisticUsageKey": [.DISK_SPACE_APIS_KEY],
    "volumeTotalCapacityKey": [.DISK_SPACE_APIS_KEY],
    "systemFreeSize": [.DISK_SPACE_APIS_KEY],
    "systemSize": [.DISK_SPACE_APIS_KEY],
    "statfs(": [.DISK_SPACE_APIS_KEY], // also covers: fstatfs(
    "statvfs(": [.DISK_SPACE_APIS_KEY], // also covers: fstatvfs(

    "activeInputModes": [.ACTIVE_KEYBOARD_APIS_KEY],

    "UserDefaults": [.USER_DEFAULTS_APIS_KEY],

    // Ref: https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_data_use_in_privacy_manifests

    "import CoreLocation": [.CORELOCATION_FRAMEWORK_KEY],
    "#import <CoreLocation/CoreLocation.h>": [.CORELOCATION_FRAMEWORK_KEY],

    "import HealthKit": [.HEALTHKIT_FRAMEWORK_KEY],
    "#import <HealthKit/HealthKit.h>": [.HEALTHKIT_FRAMEWORK_KEY],
    "#import <HealthKitUI/HealthKitUI.h>": [.HEALTHKIT_FRAMEWORK_KEY],

    "import Sentry": [.CRASH_FRAMEWORK_KEY],
    "#import <Sentry/Sentry.h>": [.CRASH_FRAMEWORK_KEY],
    // TODO: Add more third-party crash frameworks here

    "import Contacts": [.CONTACTS_FRAMEWORK_KEY],
    "#import <ContactsUI/ContactsUI.h>": [.CONTACTS_FRAMEWORK_KEY],
    "#import <Contacts/Contacts.h>": [.CONTACTS_FRAMEWORK_KEY]
]

// Look through the Frameworks Build Phase or Package Dependencies for the
// listed strings (Case Insensitive)
let SDKS_TO_CHECK: [String: RequiredReasonKey] = [
    // Ref: https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_data_use_in_privacy_manifests

    "sentry-cocoa": .CRASH_FRAMEWORK_KEY,
    "Sentry": .CRASH_FRAMEWORK_KEY,
    "CoreLocation": .CORELOCATION_FRAMEWORK_KEY,
    "HealthKit": .HEALTHKIT_FRAMEWORK_KEY,
    "Contacts": .CONTACTS_FRAMEWORK_KEY, // also covers ContactsUI
]
