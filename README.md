# IM


# MessageKit

[![CI Status](https://img.shields.io/travis/r913218338@163.com/MessageKit.svg?style=flat)](https://travis-ci.org/r913218338@163.com/MessageKit)
[![Version](https://img.shields.io/cocoapods/v/MessageKit.svg?style=flat)](https://cocoapods.org/pods/MessageKit)
[![License](https://img.shields.io/cocoapods/l/MessageKit.svg?style=flat)](https://cocoapods.org/pods/MessageKit)
[![Platform](https://img.shields.io/cocoapods/p/MessageKit.svg?style=flat)](https://cocoapods.org/pods/MessageKit)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

MessageKit is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'MessageKit'
```

## Author

r913218338@163.com, r913218338@163.com

## License

MessageKit is available under the MIT license. See the LICENSE file for more info.









merge git command

https://thoughts.t37.net/merging-2-different-git-repositories-without-losing-your-history-de7a06bba804

cd ../new-project
git remote add old-project ../old-project
git fetch old-project
git checkout -b feature/merge-old-project
git merge -S --allow-unrelated-histories old-project/master
git push origin feature/merge-old-project
git remote rm old-project

