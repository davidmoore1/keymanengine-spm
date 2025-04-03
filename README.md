# Keyman Engine SPM

This is a Swift Package Manager compatible version of the iOS Keyman Engine component of [Keyman](https://github.com/keymanapp/keyman). 
It distributes and bundles the Keyman Engine xcframework version for iOS.  It also distributes the xcframeworks that Keyman Engine
depends on and builds with Carthage during its build process. 

### Installation
Add this repo as a Swift Package dependency to your project
```
https://github.com/davidmoore1/keymanengine-spm
```

If using this in a swift package, add this repo as a dependency.
```
.package(url: "https://github.com/davidmoore1/keymanengine-spm/", .upToNextMajor(from: "0.1.0"))
```

### Usage

To get started, import this library: `import KeymanEngine` 

See the [Keyman iOS](https://github.com/keymanapp/keyman/tree/master/ios) for more info on integration of KeymanEngine. 

### Building
The primary way to build this is through the github action for this repository.  The scripts bump the last digit of the release
number (using the incrementBuildNumber.sh) script and then calls build.sh to build the release, create the tag, and copy the 
binaries to the github release. 

Changes to the XCode version being used need to be made in the .github/workspace/main.yml file.  If changes to the version
other than the last digit of the version number are required (such as for a major release), edit the KEYMAN_ENGINE_TAG in the build.sh script.
References to the version of node.js that are required by the keyman build are in the build.sh file in NODE_VERSION.

If you would like to build your own xcframework binaries run the `localbuild.sh` script on a macOS machine. 
Edit the KEYMAN_ENGINE_TAG in the build.sh script.  It will perform the build and update the Package.swift file with the new version number.
The KEYMAN_ENGINE_REPO variable in the build.sh and localbuild.sh script is the URL to the Keyman Engine repo being built.
The KEYMAN_ENGINE_CHECKOUT variable in the build.sh and the localbuild.sh script is the branch or tag being checked out.
