# MVVMRxSwiftApp

MVVMRxSwiftApp is an sample iOS App written in RxSwift using the MVVM architecture. 
This App fetches exchange rates from a web API, updates the data continously giving the user an info about Exchange Rate appreciation/depreciation and Equity value.  

[![Language](https://img.shields.io/badge/language-Swift%205.0-orange.svg)](https://swift.org)


## Getting Started

1. Clone this repository:
    ```
    git clone https://github.com/shaurya16/MVVMRxSwiftApp
   ```
   
2. Make sure you have Cocoa Pods installed. Use the command to install Pods:
    ```
     pod install
    ```

3. Open `MVVMRxSwiftApp.xcworkspace` in Xcode.


## API

The project uses the following API to fetch the data:
[https://www.freeforexapi.com/Home/Api](https://www.freeforexapi.com/Home/Api)

Points to be noted:

1. Buy/Sell rates are NOT provided by API, they are calculated within the App.
2. Percentage calculated is based on the base rate fetched during the first time the app is loaded.
3. Account currency base is USD.
4. Assumed that the position is long for USD 10,000 for each pair with base currency USD.
5. Balance is $10,000 USD * Number of forex pairings available.
6. The Margin / Invested values on panel are placeholder values.


## References

[RxSwift + MVVM: how to feed ViewModels](https://medium.com/blablacar-tech/rxswift-mvvm-66827b8b3f10)

[Kickstarter’s open source iOS App](https://github.com/kickstarter/ios-oss)
