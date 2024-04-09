# Privacy Manifest

<p align="left">
<img src="https://img.shields.io/badge/macOS_v13%2B-_?style=flat&logo=apple&label=platform">
</p>

Privacy Manifest CLI tool is a simple tool that parses an Xcode project or a
Swift Package and attempts to locate calls to Apple's required reason APIs [^1]
or privacy collected data frameworks [^2].

The tool detects and parses the source files of the project as well as the
frameworks added in the Xcode project's Build Phase. It does not perform any
sort of analysis beyond the simple line-by-line check for the existence of the
method calls or symbols that Apple has already published.

## Installation

You can either use the tool by typing: `swift run privacy-manifest` in the root
directory of the project, or you can install the executable to `/usr/local/bin`
directory so that you can call it from any folder.

In order to copy the executable, you can first build the project with
`swift build -c release` and then copy it with
`cp .build/release/privacy-manifest /usr/local/bin/privacy-manifest`.

## Usage

After installing the tool to the `/usr/local/bin` directory, you can invoke it
from any directory using the following command:

```
privacy-manifest analyze --project path/to/project --reveal-occurrences
```

The `path/to/project` can be a relative or an absolute path to the `.xcodeproj`
or `Package.swift` file of your project.

The `--reveal-occurrences` is an optional flag that displays extended information
regarding the occurrences of the required reason APIs / privacy collected data
frameworks in your codebase, highlighting the file and the line where a call has
been detected.

## Example

Below is the console output from the [VLC iOS OSS](https://github.com/videolan/vlc-ios) project (the original console output features multiple colors to emphasize certain elements and improve the readability of the results):

```
~ $ privacy-manifest analyze --project VLC.xcodeproj --reveal-occurrences

Xcode project detected.
---
✔ Parsing VLC-tvOS's Frameworks Build Phase...
✔ Parsing VLC-tvOS's source files (107/107)...
✔ Parsing VLC-iOS's Frameworks Build Phase...
✔ Parsing VLC-iOS's source files (252/252)...
---
Active keyboard APIs (0 occurrences)
Contacts (0 occurrences)
Core Location (0 occurrences)
Crash data (0 occurrences)
HealthKit (0 occurrences)
System boot time APIs (0 occurrences)

Disk space APIs (3 occurrences)
⚓︎ https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api#4278397

	✎ /Development/vlc-ios/Sources/Extensions/Devices/UIDevice+VLC.swift:
		19:	                if let totalSpace = dictionary[FileAttributeKey.systemSize] as? Int64,
		20:	                    let totalFreeSpace = dictionary[FileAttributeKey.systemFreeSize] as? Int64 {

	✎ /Development/vlc-ios/Sources/Helpers/Thumbnail Cache/VLCMediaThumbnailerCache.swift:
		119:	            let values = try fileURL.resourceValues(forKeys: [.volumeAvailableCapacityKey])


File Timestamp APIs (4 occurrences)
⚓︎ https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api#4278393

	✎ /Development/vlc-ios/Sources/Donation/Data Classes/VLCCharge.m:
		22:	        _creationDate = [NSDate dateWithTimeIntervalSince1970:[dict[@"created"] intValue]];

	✎ /Development/vlc-ios/Sources/Donation/Data Classes/VLCInvoice.m:
		22:	        _creationDate = [NSDate dateWithTimeIntervalSince1970:[dict[@"created"] intValue]];

	✎ /Development/vlc-ios/Sources/Donation/VLCDonationInvoicesViewController.m:
		168:	        cell.subtitleLabel.text = [NSDateFormatter localizedStringFromDate:invoice.creationDate dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
		178:	        cell.subtitleLabel.text = [NSDateFormatter localizedStringFromDate:charge.creationDate dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];


User defaults APIs (268 occurrences)
⚓︎ https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api#4278401

	✎ /Development/vlc-ios/Sources/About/AboutController.swift:
		182:	        let defaults = UserDefaults.standard

	✎ /Development/vlc-ios/Sources/App/iOS/TabBarCoordinator.swift:
		87:	        tabBarController.selectedIndex = UserDefaults.standard.integer(forKey: kVLCTabBarIndex)
		141:	        UserDefaults.standard.set(viewControllerIndex, forKey: kVLCTabBarIndex)

	✎ /Development/vlc-ios/Sources/App/iOS/VLCAppDelegate.m:
		38:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		38:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		38:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		157:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		157:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		157:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	✎ /Development/vlc-ios/Sources/App/tvOS/AppleTVAppDelegate.m:
		43:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		43:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		43:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	✎ /Development/vlc-ios/Sources/CarPlay/CPListTemplate+NetworkStreams.m:
		45:	        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		45:	        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		45:	        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	✎ /Development/vlc-ios/Sources/CarPlay/VLCCarPlayArtistsController.m:
		69:	    BOOL hideFeatArtists = [[NSUserDefaults standardUserDefaults] boolForKey:kVLCAudioLibraryHideFeatArtists];
		69:	    BOOL hideFeatArtists = [[NSUserDefaults standardUserDefaults] boolForKey:kVLCAudioLibraryHideFeatArtists];

	✎ /Development/vlc-ios/Sources/Cloud/Services/OneDrive/VLCOneDriveTableViewController.m:
		137:	            if (![[NSUserDefaults standardUserDefaults] boolForKey:kVLCAutomaticallyPlayNextItem]) {
		137:	            if (![[NSUserDefaults standardUserDefaults] boolForKey:kVLCAutomaticallyPlayNextItem]) {

	✎ /Development/vlc-ios/Sources/Donation/VLCStripeController.m:
		543:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		543:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		543:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	✎ /Development/vlc-ios/Sources/Extensions/Data Structures/NSObject+SettingsReader.swift:
		54:	        guard let userDefaultValue = UserDefaults.standard.value(forKey: preferenceKey) else { return nil }
		78:	        guard let userDefaultValue = UserDefaults.standard.value(forKey: preferenceKey) else { return nil }

	✎ /Development/vlc-ios/Sources/Helpers/ColorThemeExtension.swift:
		20:	            guard UserDefaults.standard.integer(forKey: kVLCSettingAppTheme) == kVLCSettingAppThemeSystem else {

	✎ /Development/vlc-ios/Sources/Helpers/KeychainCoordinator.swift:
		21:	        return UserDefaults.standard.bool(forKey: kVLCSettingPasscodeOnKey)
		28:	        var touchIDEnabled = UserDefaults.standard.bool(forKey: kVLCSettingPasscodeAllowTouchID)
		38:	        var faceIDEnabled = UserDefaults.standard.bool(forKey: kVLCSettingPasscodeAllowFaceID)

	✎ /Development/vlc-ios/Sources/Helpers/Network/URLHandler.swift:
		180:	            UserDefaults.standard.set(true, forKey: kVLCSettingAlwaysPlayURLs)
		370:	            if (UserDefaults.standard.bool(forKey: kVLCSettingAlwaysPlayURLs)) {
		417:	            if (UserDefaults.standard.bool(forKey: kVLCSettingAlwaysPlayURLs)) {

	✎ /Development/vlc-ios/Sources/Media Library/Discovery/VLCMediaFileDiscoverer.m:
		203:	            BOOL backupMediaLibrary = [NSUserDefaults.standardUserDefaults boolForKey:kVLCSettingBackupMediaLibrary];
		203:	            BOOL backupMediaLibrary = [NSUserDefaults.standardUserDefaults boolForKey:kVLCSettingBackupMediaLibrary];
		229:	    BOOL hideMediaLibrary = [NSUserDefaults.standardUserDefaults boolForKey:kVLCSettingHideLibraryInFilesApp];
		229:	    BOOL hideMediaLibrary = [NSUserDefaults.standardUserDefaults boolForKey:kVLCSettingHideLibraryInFilesApp];

	✎ /Development/vlc-ios/Sources/Media Library/MediaCategories/MediaCategoryViewController.swift:
		43:	    private let userDefaults = UserDefaults.standard
		453:	        if let sortingCriteriaDefault = UserDefaults.standard.value(forKey: "\(kVLCSortDefault)\(model.name)") as? UInt {
		458:	        let desc = UserDefaults.standard.bool(forKey: "\(kVLCSortDescendingDefault)\(model.name)")

	✎ /Development/vlc-ios/Sources/Media Library/MediaCategoryCells/MediaCollectionViewCell.swift:
		109:	        return !UserDefaults.standard.bool(forKey: kVLCSettingEnableMediaCellTextScrolling)
		268:	        let displayTrackNumber: Bool = !UserDefaults.standard.bool(forKey: kVLCAudioLibraryHideTrackNumbers)

	✎ /Development/vlc-ios/Sources/Media Library/MediaCategoryCells/MediaGridCollectionCell.swift:
		18:	    private let userDefaults = UserDefaults.standard

	✎ /Development/vlc-ios/Sources/Media Library/MediaCategoryCells/MovieCollectionViewCell.swift:
		168:	        guard let value = UserDefaults.standard.value(forKey: kVLCSettingContinuePlayback) as? Int else {

	✎ /Development/vlc-ios/Sources/Media Library/MediaLibraryModel/AlbumModel.swift:
		25:	        return UserDefaults.standard.bool(forKey: "\(kVLCAudioLibraryGridLayout)\(name)") ? MediaGridCollectionCell.self : MediaCollectionViewCell.self

	✎ /Development/vlc-ios/Sources/Media Library/MediaLibraryModel/ArtistModel.swift:
		23:	        return UserDefaults.standard.bool(forKey: "\(kVLCAudioLibraryGridLayout)\(name)") ? MediaGridCollectionCell.self : MediaCollectionViewCell.self
		33:	        return UserDefaults.standard.bool(forKey: "\(kVLCAudioLibraryHideFeatArtists)")

	✎ /Development/vlc-ios/Sources/Media Library/MediaLibraryModel/CollectionModel.swift:
		31:	            return UserDefaults.standard.bool(forKey: "\(kVLCVideoLibraryGridLayout)\(String(describing: type(of: mediaCollection)) + name)") ?
		34:	            return UserDefaults.standard.bool(forKey: "\(kVLCAudioLibraryGridLayout)\(String(describing: type(of: mediaCollection)) + name)") ?

	✎ /Development/vlc-ios/Sources/Media Library/MediaLibraryModel/GenreModel.swift:
		23:	        return UserDefaults.standard.bool(forKey: "\(kVLCAudioLibraryGridLayout)\(name)") ? MediaGridCollectionCell.self : MediaCollectionViewCell.self

	✎ /Development/vlc-ios/Sources/Media Library/MediaLibraryModel/MediaGroupViewModel.swift:
		24:	        return UserDefaults.standard.bool(forKey: "\(kVLCVideoLibraryGridLayout)\(name)") ? MovieCollectionViewCell.self : MediaCollectionViewCell.self

	✎ /Development/vlc-ios/Sources/Media Library/MediaLibraryModel/MediaLibraryBaseModel.swift:
		152:	            || (!UserDefaults.standard.bool(forKey: kVLCSettingShowThumbnails) && self is VLCMLMediaGroup)
		153:	            || (!UserDefaults.standard.bool(forKey: kVLCSettingShowArtworks) && !(self is VLCMLMediaGroup)) {

	✎ /Development/vlc-ios/Sources/Media Library/MediaLibraryModel/MediaModel.swift:
		61:	            || (!UserDefaults.standard.bool(forKey: kVLCSettingShowThumbnails) && subtype() != .albumTrack)
		62:	            || (!UserDefaults.standard.bool(forKey: kVLCSettingShowArtworks) && subtype() == .albumTrack) {
		81:	        if UserDefaults.standard.bool(forKey: kVLCOptimizeItemNamesForDisplay) == true

	✎ /Development/vlc-ios/Sources/Media Library/MediaLibraryModel/PlaylistModel.swift:
		24:	        return UserDefaults.standard.bool(forKey: "\(kVLCAudioLibraryGridLayout)\(name)") ? MovieCollectionViewCell.self : MediaCollectionViewCell.self

	✎ /Development/vlc-ios/Sources/Media Library/MediaLibraryModel/TrackModel.swift:
		23:	        return UserDefaults.standard.bool(forKey: "\(kVLCAudioLibraryGridLayout)\(name)") ? MediaGridCollectionCell.self : MediaCollectionViewCell.self

	✎ /Development/vlc-ios/Sources/Media Library/MediaLibraryModel/VideoModel.swift:
		23:	        return UserDefaults.standard.bool(forKey: "\(kVLCVideoLibraryGridLayout)\(name)") ? MovieCollectionViewCell.self : MediaCollectionViewCell.self

	✎ /Development/vlc-ios/Sources/Media Library/MediaLibraryService.swift:
		186:	        let excludeMediaLibrary = !UserDefaults.standard.bool(forKey: kVLCSettingBackupMediaLibrary)
		187:	        let hideML = UserDefaults.standard.bool(forKey: kVLCSettingHideLibraryInFilesApp)
		191:	        if UserDefaults.standard.bool(forKey: MediaLibraryService.didForceRescan) == false {
		193:	            UserDefaults.standard.set(true, forKey: MediaLibraryService.didForceRescan)

	✎ /Development/vlc-ios/Sources/Media Library/MediaViewControllers/MediaViewController.swift:
		524:	            let isIncludeAllArtistActive = UserDefaults.standard.bool(forKey: kVLCAudioLibraryHideFeatArtists)
		536:	            let hideTrackNumbers = UserDefaults.standard.bool(forKey: kVLCAudioLibraryHideTrackNumbers)

	✎ /Development/vlc-ios/Sources/Media Library/tvOS/VLCMicroMediaLibraryService.m:
		116:	    if ([[NSUserDefaults standardUserDefaults] boolForKey:kVLCSaveDebugLogs]) {
		116:	    if ([[NSUserDefaults standardUserDefaults] boolForKey:kVLCSaveDebugLogs]) {

	✎ /Development/vlc-ios/Sources/Network/Favorite/iOS/VLCFavoriteListViewController.swift:
		33:	    let userDefaults: UserDefaults = UserDefaults.standard
		33:	    let userDefaults: UserDefaults = UserDefaults.standard

	✎ /Development/vlc-ios/Sources/Network/Login/Data Sources/VLCNetworkLoginDataSourceSavedLogins.m:
		55:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		55:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		55:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	✎ /Development/vlc-ios/Sources/Network/Managed Servers/VLCOpenManagedServersViewController.m:
		36:	        NSDictionary *managedConf = [NSUserDefaults.standardUserDefaults dictionaryForKey:@"com.apple.configuration.managed"];
		36:	        NSDictionary *managedConf = [NSUserDefaults.standardUserDefaults dictionaryForKey:@"com.apple.configuration.managed"];

	✎ /Development/vlc-ios/Sources/Network/Open Network Stream/VLCOpenNetworkStreamTVViewController.m:
		79:	        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		79:	        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		79:	        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		91:	        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		91:	        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		91:	        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		180:	            [[NSUserDefaults standardUserDefaults] setObject:_recentURLs forKey:kVLCRecentURLs];
		180:	            [[NSUserDefaults standardUserDefaults] setObject:_recentURLs forKey:kVLCRecentURLs];
		222:	                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		222:	                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		222:	                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		338:	        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		338:	        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		338:	        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		389:	        [[NSUserDefaults standardUserDefaults] setObject:_recentURLTitles forKey:kVLCRecentURLTitles];
		389:	        [[NSUserDefaults standardUserDefaults] setObject:_recentURLTitles forKey:kVLCRecentURLTitles];

	✎ /Development/vlc-ios/Sources/Network/Open Network Stream/VLCOpenNetworkStreamViewController.m:
		32:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		32:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		32:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		96:	        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		96:	        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		96:	        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		108:	        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		108:	        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		108:	        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		211:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		211:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		211:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		228:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		228:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		228:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		516:	        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		516:	        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		516:	        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	✎ /Development/vlc-ios/Sources/Network/Server Browsing/Data/Protocols/General/VLCLocalNetworkServiceBrowserMediaDiscoverer.m:
		45:	            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		45:	            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		45:	            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	✎ /Development/vlc-ios/Sources/Network/Server Browsing/Data/Protocols/SMB/VLCLocalNetworkServiceBrowserDSM.m:
		113:	    if ([[NSUserDefaults standardUserDefaults] boolForKey:kVLCForceSMBV1]) {
		113:	    if ([[NSUserDefaults standardUserDefaults] boolForKey:kVLCForceSMBV1]) {

	✎ /Development/vlc-ios/Sources/Network/Server Browsing/View Controllers/VLCNetworkServerBrowserViewController.m:
		247:	    BOOL singlePlayback = ![[NSUserDefaults standardUserDefaults] boolForKey:kVLCAutomaticallyPlayNextItem];
		247:	    BOOL singlePlayback = ![[NSUserDefaults standardUserDefaults] boolForKey:kVLCAutomaticallyPlayNextItem];

	✎ /Development/vlc-ios/Sources/Network/Server Browsing/View Controllers/VLCServerBrowsingTVViewController.m:
		50:	        self.downloadArtwork = [[NSUserDefaults standardUserDefaults] boolForKey:kVLCSettingDownloadArtwork];
		50:	        self.downloadArtwork = [[NSUserDefaults standardUserDefaults] boolForKey:kVLCSettingDownloadArtwork];
		287:	    const BOOL singlePlayback = ![[NSUserDefaults standardUserDefaults] boolForKey:kVLCAutomaticallyPlayNextItem];
		287:	    const BOOL singlePlayback = ![[NSUserDefaults standardUserDefaults] boolForKey:kVLCAutomaticallyPlayNextItem];

	✎ /Development/vlc-ios/Sources/Network/Server List/VLCServerListViewController.m:
		81:	        if ([[NSUserDefaults standardUserDefaults] integerForKey:kVLCSettingAppTheme] == kVLCSettingAppThemeSystem) {
		81:	        if ([[NSUserDefaults standardUserDefaults] integerForKey:kVLCSettingAppTheme] == kVLCSettingAppThemeSystem) {

	✎ /Development/vlc-ios/Sources/Playback/Control/VLCPlaybackService.m:
		210:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		210:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		210:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		229:	    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		229:	    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		229:	    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		318:	    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		318:	    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		318:	    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		513:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		513:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		513:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		752:	            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		752:	            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		752:	            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		766:	            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		766:	            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		766:	            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		882:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		882:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		882:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		951:	        NSNumber *skipLength = [[NSUserDefaults standardUserDefaults] valueForKey:kVLCSettingPlaybackForwardSkipLength];
		951:	        NSNumber *skipLength = [[NSUserDefaults standardUserDefaults] valueForKey:kVLCSettingPlaybackForwardSkipLength];
		1017:	        NSNumber *skipLength = [[NSUserDefaults standardUserDefaults] valueForKey:kVLCSettingPlaybackBackwardSkipLength];
		1017:	        NSNumber *skipLength = [[NSUserDefaults standardUserDefaults] valueForKey:kVLCSettingPlaybackBackwardSkipLength];
		1279:	    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		1279:	    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		1279:	    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		1321:	    return [[NSUserDefaults standardUserDefaults] floatForKey:kVLCSettingDefaultPreampLevel];
		1321:	    return [[NSUserDefaults standardUserDefaults] floatForKey:kVLCSettingDefaultPreampLevel];
		1349:	    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		1349:	    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		1349:	    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		1465:	            continuePlayback = [[[NSUserDefaults standardUserDefaults] objectForKey:kVLCSettingContinueAudioPlayback] integerValue];
		1465:	            continuePlayback = [[[NSUserDefaults standardUserDefaults] objectForKey:kVLCSettingContinueAudioPlayback] integerValue];
		1470:	            continuePlayback = [[[NSUserDefaults standardUserDefaults] objectForKey:kVLCSettingContinuePlayback] integerValue];
		1470:	            continuePlayback = [[[NSUserDefaults standardUserDefaults] objectForKey:kVLCSettingContinuePlayback] integerValue];
		1585:	        && ![[[NSUserDefaults standardUserDefaults] objectForKey:kVLCSettingContinueAudioInBackgroundKey] boolValue]) {
		1585:	        && ![[[NSUserDefaults standardUserDefaults] objectForKey:kVLCSettingContinueAudioInBackgroundKey] boolValue]) {
		1637:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		1637:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		1637:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	✎ /Development/vlc-ios/Sources/Playback/Control/VLCPlayerDisplayController.m:
		61:	        [[NSUserDefaults standardUserDefaults] registerDefaults:@{VLCPlayerDisplayControllerDisplayModeKey : @(VLCPlayerDisplayControllerDisplayModeFullscreen)}];
		61:	        [[NSUserDefaults standardUserDefaults] registerDefaults:@{VLCPlayerDisplayControllerDisplayModeKey : @(VLCPlayerDisplayControllerDisplayModeFullscreen)}];
		87:	    return [[NSUserDefaults standardUserDefaults] integerForKey:VLCPlayerDisplayControllerDisplayModeKey];
		87:	    return [[NSUserDefaults standardUserDefaults] integerForKey:VLCPlayerDisplayControllerDisplayModeKey];
		92:	    [[NSUserDefaults standardUserDefaults] setInteger:displayMode forKey:VLCPlayerDisplayControllerDisplayModeKey];
		92:	    [[NSUserDefaults standardUserDefaults] setInteger:displayMode forKey:VLCPlayerDisplayControllerDisplayModeKey];
		151:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		151:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		151:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		592:	    NSInteger seekBy = [[NSUserDefaults standardUserDefaults] integerForKey:kVLCSettingPlaybackBackwardSkipLength];
		592:	    NSInteger seekBy = [[NSUserDefaults standardUserDefaults] integerForKey:kVLCSettingPlaybackBackwardSkipLength];
		598:	    NSInteger seekBy = [[NSUserDefaults standardUserDefaults] integerForKey:kVLCSettingPlaybackForwardSkipLength];
		598:	    NSInteger seekBy = [[NSUserDefaults standardUserDefaults] integerForKey:kVLCSettingPlaybackForwardSkipLength];

	✎ /Development/vlc-ios/Sources/Playback/OS Integration/VLCRemoteControlService.m:
		79:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		79:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		79:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	✎ /Development/vlc-ios/Sources/Playback/Player/AudioPlayer/AudioPlayerView.swift:
		534:	        let displaySecondaryStackView: Bool = UserDefaults.standard.bool(forKey: kVLCPlayerShowPlaybackSpeedShortcut)

	✎ /Development/vlc-ios/Sources/Playback/Player/AudioPlayer/AudioPlayerViewController.swift:
		105:	        let displayShortcutView: Bool = UserDefaults.standard.bool(forKey: kVLCPlayerShowPlaybackSpeedShortcut)

	✎ /Development/vlc-ios/Sources/Playback/Player/PlayerViewController.swift:
		634:	        let defaults = UserDefaults.standard

	✎ /Development/vlc-ios/Sources/Playback/Player/VideoPlayer-iOS/MediaScrubProgressBar.swift:
		132:	        let timeToDisplay = UserDefaults.standard.bool(forKey: kVLCShowRemainingTime)
		151:	        if UserDefaults.standard.bool(forKey: kVLCShowRemainingTime) {
		291:	        let userDefault = UserDefaults.standard
		318:	            if UserDefaults.standard.bool(forKey: kVLCShowRemainingTime) {

	✎ /Development/vlc-ios/Sources/Playback/Player/VideoPlayer-iOS/PlayerController.swift:
		41:	    // MARK: - UserDefaults computed properties getters
		44:	        return UserDefaults.standard.bool(forKey: kVLCShowRemainingTime)
		48:	        return UserDefaults.standard.bool(forKey: kVLCSettingVolumeGesture)
		52:	        return UserDefaults.standard.bool(forKey: kVLCSettingPlayPauseGesture)
		56:	        return UserDefaults.standard.bool(forKey: kVLCSettingBrightnessGesture)
		60:	        return UserDefaults.standard.bool(forKey: kVLCSettingSeekGesture)
		64:	        return UserDefaults.standard.bool(forKey: kVLCSettingCloseGesture)
		68:	        return UserDefaults.standard.bool(forKey: kVLCPlayerIsShuffleEnabled)
		72:	        let storedValue = UserDefaults.standard.integer(forKey: kVLCPlayerIsRepeatEnabled)
		78:	        return UserDefaults.standard.bool(forKey: kVLCPlayerShouldRememberState)
		87:	    func updateUserDefaults() {

	✎ /Development/vlc-ios/Sources/Playback/Player/VideoPlayer-iOS/Subviews/EqualizerView.swift:
		217:	        snapBandsSwitch.isOn = UserDefaults.standard.bool(forKey: kVLCEqualizerSnapBands)
		417:	        UserDefaults.standard.setValue(sender.isOn, forKey: kVLCEqualizerSnapBands)
		442:	        let preampValue = UserDefaults.standard.float(forKey: kVLCSettingDefaultPreampLevel)

	✎ /Development/vlc-ios/Sources/Playback/Player/VideoPlayer-iOS/Subviews/PlaybackSpeedView.swift:
		53:	    private var defaultSpeed: Float = UserDefaults.standard.float(forKey: kVLCSettingPlaybackSpeedDefaultValue)
		167:	        shortcutSwitch.isOn = UserDefaults.standard.bool(forKey: kVLCPlayerShowPlaybackSpeedShortcut)
		267:	        defaultSpeed = UserDefaults.standard.float(forKey: kVLCSettingPlaybackSpeedDefaultValue)
		348:	        UserDefaults.standard.setValue(isSwitchOn, forKey: kVLCPlayerShowPlaybackSpeedShortcut)

	✎ /Development/vlc-ios/Sources/Playback/Player/VideoPlayer-iOS/VideoPlayerViewController.swift:
		330:	        let defaults = UserDefaults.standard
		645:	        let defaults = UserDefaults.standard
		714:	        let defaults = UserDefaults.standard
		876:	        let defaults = UserDefaults.standard

	✎ /Development/vlc-ios/Sources/Playback/Player/VideoPlayer-tvOS/Playback Info/VLCPlaybackInfoPlaybackTVViewController.m:
		96:	    _defaultSpeed = [[[NSUserDefaults standardUserDefaults] valueForKey:kVLCSettingPlaybackSpeedDefaultValue] doubleValue];
		96:	    _defaultSpeed = [[[NSUserDefaults standardUserDefaults] valueForKey:kVLCSettingPlaybackSpeedDefaultValue] doubleValue];

	✎ /Development/vlc-ios/Sources/Playback/Player/VideoPlayer-tvOS/Playback Info/VLCPlaybackInfoTracksTVViewController.m:
		107:	        if ([[NSUserDefaults standardUserDefaults] boolForKey:kVLCSettingUseSPDIF]) {
		107:	        if ([[NSUserDefaults standardUserDefaults] boolForKey:kVLCSettingUseSPDIF]) {
		132:	        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		132:	        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		132:	        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	✎ /Development/vlc-ios/Sources/Playback/Player/VideoPlayer-tvOS/VLCFullscreenMovieTVViewController.m:
		166:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		166:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		166:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	✎ /Development/vlc-ios/Sources/Playback/Subtitles Downloading/VLCPlaybackInfoSubtitlesFetcherViewController.m:
		59:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		59:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		59:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		174:	        if ([[NSUserDefaults standardUserDefaults] integerForKey:kVLCSettingAppTheme] == kVLCSettingAppThemeSystem) {
		174:	        if ([[NSUserDefaults standardUserDefaults] integerForKey:kVLCSettingAppTheme] == kVLCSettingAppThemeSystem) {
		226:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		226:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		226:	    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		318:	        NSString *selectedLocale = [[NSUserDefaults standardUserDefaults] objectForKey:kVLCSettingLastUsedSubtitlesSearchLanguage];
		318:	        NSString *selectedLocale = [[NSUserDefaults standardUserDefaults] objectForKey:kVLCSettingLastUsedSubtitlesSearchLanguage];
		360:	        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		360:	        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		360:	        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	✎ /Development/vlc-ios/Sources/Settings/Controller/PasscodeLockController.swift:
		29:	    private let userDefaults = UserDefaults.standard

	✎ /Development/vlc-ios/Sources/Settings/Controller/SettingsController.swift:
		29:	    private let userDefaults = UserDefaults.standard
		289:	                let userDefaults = UserDefaults.standard

	✎ /Development/vlc-ios/Sources/Settings/Model/ActionSheetSpecifier.swift:
		22:	    private let userDefaults = UserDefaults.standard
		150:	            cell.setToggleSwitch(state: UserDefaults.standard.bool(forKey: kVLCSettingAppThemeBlack))

	✎ /Development/vlc-ios/Sources/Settings/Model/SettingsSection.swift:
		348:	        let forwardBackwardEqual = UserDefaults.standard.bool(forKey: kVLCSettingPlaybackForwardBackwardEqual)
		349:	        let tapSwipeEqual = UserDefaults.standard.bool(forKey: kVLCSettingPlaybackTapSwipeEqual)

	✎ /Development/vlc-ios/Sources/Settings/View/SettingsCell.swift:
		39:	    private let userDefaults = UserDefaults.standard
		209:	                                       name: UserDefaults.didChangeNotification,

	✎ /Development/vlc-ios/Sources/Settings/tvOS/VLCSettingsViewController.m:
		25:	@property (strong, nonatomic) NSUserDefaults *userDefaults;
		39:	    self.userDefaults = [NSUserDefaults standardUserDefaults];
		39:	    self.userDefaults = [NSUserDefaults standardUserDefaults];
		247:	                [[NSUserDefaults standardUserDefaults] setValue:dico[@"DefaultValue"] forKey:dico[@"Key"]];
		247:	                [[NSUserDefaults standardUserDefaults] setValue:dico[@"DefaultValue"] forKey:dico[@"Key"]];

	✎ /Development/vlc-ios/Sources/UI Elements/ActionSheet/ActionSheetSortSectionHeader.swift:
		33:	    private let userDefaults = UserDefaults.standard
		199:	        setSwitchIsOnFromUserDefaults()
		213:	            setSwitchIsOnFromUserDefaults()
		253:	    private func setSwitchIsOnFromUserDefaults() {
		255:	        layoutChangeSwitch.isOn = UserDefaults.standard.bool(forKey: key + modelType)
		299:	        hideFeatArtistsSwitch.isOn = UserDefaults.standard.bool(forKey: kVLCAudioLibraryHideFeatArtists)
		309:	        hideTrackNumbersSwitch.isOn = UserDefaults.standard.bool(forKey: kVLCAudioLibraryHideTrackNumbers)

	✎ /Development/vlc-ios/Sources/UI Elements/PresentationTheme.swift:
		120:	        return UserDefaults.standard.bool(forKey: kVLCSettingAppThemeBlack)
		124:	        let themeSettings = UserDefaults.standard.integer(forKey: kVLCSettingAppTheme)
		147:	        let themeSettings = UserDefaults.standard.integer(forKey: kVLCSettingAppTheme)
		160:	        if UserDefaults.standard.bool(forKey: kVLCSettingAppThemeBlack) {

	✎ /Development/vlc-ios/Sources/WiFi Sharing/VLCHTTPUploaderController.m:
		63:	        BOOL isHTTPServerOn = [[NSUserDefaults standardUserDefaults] boolForKey:kVLCSettingSaveHTTPUploadServerStatus];
		63:	        BOOL isHTTPServerOn = [[NSUserDefaults standardUserDefaults] boolForKey:kVLCSettingSaveHTTPUploadServerStatus];
		75:	        [self changeHTTPServerState:[[NSUserDefaults standardUserDefaults] boolForKey:kVLCSettingSaveHTTPUploadServerStatus]];
		75:	        [self changeHTTPServerState:[[NSUserDefaults standardUserDefaults] boolForKey:kVLCSettingSaveHTTPUploadServerStatus]];
		256:	    [_httpServer setIPv6Enabled:[[[NSUserDefaults standardUserDefaults] objectForKey:kVLCSettingWiFiSharingIPv6] boolValue]];
		256:	    [_httpServer setIPv6Enabled:[[[NSUserDefaults standardUserDefaults] objectForKey:kVLCSettingWiFiSharingIPv6] boolValue]];

	✎ /Development/vlc-ios/Sources/WiFi Sharing/VLCWiFiUploadTableViewCell.m:
		129:	    [[NSUserDefaults standardUserDefaults] setBool:futureHTTPServerState forKey:kVLCSettingSaveHTTPUploadServerStatus];
		129:	    [[NSUserDefaults standardUserDefaults] setBool:futureHTTPServerState forKey:kVLCSettingSaveHTTPUploadServerStatus];
		132:	    [[NSUserDefaults standardUserDefaults] synchronize];
		132:	    [[NSUserDefaults standardUserDefaults] synchronize];

	✎ /Development/vlc-ios/Sources/WiFi Sharing/tvOS/VLCRemotePlaybackViewController.m:
		148:	    [[NSUserDefaults standardUserDefaults] setBool:futureHTTPServerState forKey:kVLCSettingSaveHTTPUploadServerStatus];
		148:	    [[NSUserDefaults standardUserDefaults] setBool:futureHTTPServerState forKey:kVLCSettingSaveHTTPUploadServerStatus];
		151:	    [[NSUserDefaults standardUserDefaults] synchronize];
		151:	    [[NSUserDefaults standardUserDefaults] synchronize];

Execution took 6.693006916999999 seconds
```

## Future implementations

There are several ideas that can be explored here, beyond the typical performance
optimizations: The tool can output the report to HTML, or attempt to generate
an initial privacy manifest based on the user's input (maybe it can be more
interactive).

On top of that, it can also look into Apple's SDK list that require a privacy
manifest to be present [^3] and even update the list of third-party crash
frameworks so that it can inform the user when such framework is detected
(there is a related TODO in the code).

## Disclaimer

Do not use this tool alone to create your privacy manifest file for your app or
SDK. You must always double-check the occurrences that the tool displays as the
tool does not know whether a certain occurrence is included in a comment or on
an used piece of code. Furthermore, there might also be cases where something
has not been included in the parsing process.

This tool gives you a high-level overview of the different required reason APIs
and privacy collected data frameworks your project / package uses, so always do
your own research after using this tool, to confirm the findings.

## License

Licensed under Apache License 2.0, see [LICENSE](LICENSE) file.

[^1]: https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api
[^2]: https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_data_use_in_privacy_manifests).
[^3]: https://developer.apple.com/support/third-party-SDK-requirements/
