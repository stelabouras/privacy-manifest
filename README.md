# Privacy Manifest

<p align="left">
<img src="https://img.shields.io/badge/macOS_v13%2B-_?style=flat&logo=apple&label=platform">
</p>

Privacy Manifest CLI tool is a simple tool that parses an Xcode project or a
Swift Package and attempts to locate calls to Apple's required reason APIs [^1]
or privacy collected data frameworks [^2].

The tool detects and parses the source files of the project as well as the
frameworks added in the Xcode project's Build Phase or in the Swift Package
dependencies. It does not perform any sort of analysis beyond the simple
line-by-line check for the existence of the method calls or symbols that
Apple has already published.

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

Below is the console output from the [VLC iOS OSS](https://github.com/videolan/vlc-ios).

![Privacy Manifest analyze running for VLC iOS project](https://raw.githubusercontent.com/stelabouras/privacy-manifest/main/.github/privacymanifest-vlc.gif)

## Future implementations

There are several ideas that can be explored here, beyond the typical performance
optimizations: The tool can output the report to HTML, or attempt to generate
an initial privacy manifest based on the user's input (maybe it can be more
interactive).

On top of that, the list of third-party crash frameworks can be updated so that
it can inform the user when such framework is detected (there is a related TODO
in the code).

## Disclaimer

Do not use this tool alone to create your privacy manifest file for your app or
SDK. You must always double-check the occurrences that the tool displays as the
tool does not know whether a certain occurrence is included in a comment or on
an unused piece of code. Furthermore, there might also be cases where something
has not been included in the parsing process.

This tool gives you a high-level overview of the different required reason APIs
and privacy collected data frameworks your project / package uses, so always do
your own research after using this tool, to confirm the findings.

## License

Licensed under Apache License 2.0, see [LICENSE](LICENSE) file.

[^1]: https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api
[^2]: https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_data_use_in_privacy_manifests).
[^3]: https://developer.apple.com/support/third-party-SDK-requirements/
