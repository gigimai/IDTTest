# IDTTest

IDTTest is an iOS application that fetchs weather data from [OpenWeatherMap](http://openweathermap.org/). Currently it will fetch the data of the current date only.

## Support

* iOS 8.0 and later
* XCode 7.3
* Main code is implemeneted in Objective C, Unit tests are implemented in Swift.

## Installations

Open up Terminal, `cd` to your top-level project directory

```
$ git clone git@github.com:gigimai/IDTTest.git
```

Go to IDTTest root directory

```
$ cd [project_path]
```

The project uses Cocoapods, please do the following:

```
$ open IDTTest.xcworkspace/
```

## Cocoapods Dependency

* [AFNetworking 2.0](https://github.com/AFNetworking/AFNetworking)
* [SVProgressHUD](https://github.com/SVProgressHUD/SVProgressHUD)


## About the questions
1.  Write a function which takes a string as argument and returns the string reversed. For example, "abcdef" becomes "fedcba". Do not use the reverse method. Does it work with emojis?

You can find the implementation [HERE](https://github.com/gigimai/IDTTest/blob/master/IDTTest/NSString%2BUtilities.m) and unit test [HERE](https://github.com/gigimai/IDTTest/blob/master/IDTTestTests/NSStringUtilTests.swift). I have explained in the comment section. At the first glance I would go with `NSMutableString` which iterate through the input string and append the last character to the result, but after a certain amount of Google queries and I've found the solution with UTF32Encoding works better in terms of performance and it does work emojis, just in case a developer forgets to use recommended `rangeOfComposedCharacterSequencesForRange:`. There is another solution using `memCopy` but in my humble opinion the algorithm looks complicated and the performance speed is slightly slower than using UTF32Encoding.

2.  Explain what happens when the following code is executed (ARC being disabled in the compiler):

```
MyClass *myClass = [[[[MyClass alloc] init] autorelease] autorelease];
```

What this code does is add the object of `MyClass` to the current autorelease pool twice, which is going to be drained at the end of run loop iteration. This code makes a perfect nonsense, but it won't crash immediately because `myClass` stays valid until the pool is drained, what actually would happen is undefined, the behavior could manifest in any number of way but it tends to get more likely to crash.


## Rants

I was tempted to try with some JSON Mapper like [JSONModel](https://github.com/JSONModel/JSONModel) but taking a look at [OpenWeatherMap API JSON Response](http://openweathermap.org/current#current_JSON) I notice that they use `description` as a key, so it will make it super difficult for me to map it to `NSObject` since `description` is a reserved key >.< This just makes me so sad just by looking at all those magic strings in the model class. I wish I could have more time to investigate other ways of JSON mapping or data serialization/deserialization. I've found out that [Apache Thrift](http://thrift.apache.org) looks promising but their website is broken often, plus I couldn't find a place to download their latest source, the Thrift version I am using does not support ARC.
