install:
		swift package update
		swift build -c release
		install .build/release/privacy-manifest /usr/local/bin/privacy-manifest
