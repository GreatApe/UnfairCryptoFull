UnfairCrypto: Algorithmic crypto trading for the masses
======

![platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20macOS-333333.svg) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Unfair Crypto is the quickest and simplest way to get started with algorithmic trading of crypto currencies (and derivatives). The public version currently supports the full functionality of Binance, and in the coming months all crypto exchanges that provide APIs will be added. Unfair Crypto requires a Mac and uses [Swift](https://developer.apple.com/swift/), Apple's new programming language. But you don't need to know Swift to get started using the platform! Unfair Crypto is designed for ease of use, safety and complete coverage functionality.

* [Background](#background)
* [Usage](#usage)
* [Requirements](#requirements)
* [Installation](#installation)
* [Tutorial](#tutorial)
* [Roadmap](#roadmap)
* [Feedback](#feedback)
* [Consulting](#consulting)

## Background

Unfair Advantage is a Scandinavian software development company that specialises in very challenging projects within fields such as drone and fintech, and Unfair Crypto was built by Unfair Advantage founder Gustaf Kugelberg for the [Skye Crypto fund](https://skyecrypto.com), a crypto arbitrage fund that he co-founded. The fund needed a reliable toolchain to facilitated fast iteration and minimise the time spent fixing bugs and the result is the UnfairCrypto platform, which is gradually being open-sourced. It is designed to be extremely easy to use and highly extensible, and now anyone can use it to implement their crypto trading ideas, build visualisation tools or any other crypto related Mac or iOS app they can imagine.

The first part of the platform to be released is the interface for obtaining data from and placing orders at Binance. Over time the entire toolchain will be open-sourced, and all major exchanges will be supported.

## Usage

Unfair Crypto covers the entire API of Binance, which in turn means that anything you can do in the web interface you can also do with Unfair Crypto -- from getting the latest quotes to placing complex interlinked orders.

### Examples

Places a simple limit order for 2500 Cardano's at a price of 0.00003750 BT/ADAC, and prints the order status

```swift

// Sets up your API key and secret
Binance.setup(id: "My API id", secret: "My API secret")

// Places a simple limit buy order for 8 Cardanos's at a price of 0.00003750 BTC, and prints the order status
func handleOrderResponse(response: BnResponse.Order.Full) {
  print("Orderstatus: \(response.status)")
}

Binance.rest
  .order
  .limit(symbol: .adabtc, side: .buy, timeInForce: .goodTillCancel, quantity: 1000, price: 0.00003750)
  .handled(by: handleOrderResponse)
```

## Requirements
We have some very exciting things in the pipeline that will change this, but at the moment, you need a Mac to get started with algorithmic crypto trading using Unfair Crypto. You can also use a [Hackintosh](https://hackintosh.com/) or a [virtual Mac](https://techsviewer.com/install-macos-high-sierra-vmware-windows/).

## Installation

The steps below outline the installation process, and the tutorial goes through everything in detail. The whole process takes less than 30 minutes and is entirely free.

* Create an [Apple ID](https://appleid.apple.com)
* Enroll in the [Apple developer programme](https://developer.apple.com/programs/enroll/)
* Download and install [XCode](https://developer.apple.com/xcode/)
* Create an account at [Binance](https://www.Binance.com)
* Create API keys at the exchange.
* Create an app and add Unfair Crypto to your app using Carthage (`github UnfairAdvantage/UnfairCrypto`) (or use our app template)
* Profit

## Tutorial

[Tutorials and instructions](Tutorial)

## Roadmap

Over the coming months, we will be rolling out a number of exciting features, including:

* Support for all major crypto exchanges
* Useful template trading apps that you can leverage to implement your own algorithms even faster
* Built-in support for RxSwift
* New platforms, making algo trading even more accessible

## Feedback

Create an issue here on Github or get in touch at info@unfair.me

## Consulting

Get in touch with us at [Unfair Advantage](hhtps://unfair.me) for enquiries about custom requirements or full implementations of your trading ideas.
