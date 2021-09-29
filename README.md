# Promise

軽量かつシンプルなSwiftのPromise実装です。

## 使い方

ベーシックな使い方

```swift
let promise = Promise<Int, Never> { resolve, reject in
    resolve(10)
}

promise
    .map{ $0 * 10 } 
    .sink{ print($0) } // 100
    
let imageData = URLSession.shared.data(for: URL(string: "https://example.com/image.png))

imageData
    .sink{ print($0) } 
```



Async・Awaitをサポートしています。

```swift
let dataPromsie = Promise<Int, Never> { resolve, reject in
	// download data
}

asyncHandler { await in
    let data = await | dataPromsie
	let image = await | UIImage.async(data: data)
              
	print(image.size)
}
```



## Operators

- `map`

  Outputをクロージャで変換します。

- `flatMap`

  クロージャの返り値のPromiseと連結します。

- `tryMap`

  throwsなクロージャを実行して失敗した場合は以降のPromiseを失敗にします。

- `tryFlatMap`

  throwsなクロージャを実行して失敗した場合は以降のPromiseを失敗にします。

- `mapError`

  Failureをクロージャで変換します。

- `replaceError`

  Failureを引数のOutputで置き換えます。

- `eraseToError`

  Failureの型をErrorに変換します。

- `eraseToVoid`

  Outputの方をVoidに変換します。

- `peek`

  Outputの場合にクロージャを実行します。以降にOperatorを接続することができます。

- `peekError`

  Failureの場合にクロージャを実行します。以降にOperatorを接続することができます。

- `sink`

  Outputの場合にクロージャを実行します。以降にOperatorを接続することができません。

- `catch`

  Failureの場合にクロージャを実行します。以降にOperatorを接続することができません。



##### Operator接続の例

```swift
let dataPromise: Promise<Data, Error> = ...

dataPromise
	.map{ 
        // 値の変換
    }
	.peek{
        // アクションの実行
    }
	.catch{ 
        // エラーのハンドリング
    }
```



## Async・Awaitの使用

`asyncHandler`を用いることでAsync・Awaitを使用することができます。



```swift
let dataPromise: Promise<Data, Error> = ...
let intPromise: Promise<Int, Never> = ...

let promise = asyncHandler { await in
	// promiseのawait
	let data = try await | dataPromise
	// FailureがNeverの場合はtryはいらない
	let int = await | intPromise
	
              
	return "Hello World" 
}

// 返り値をOutput、投げられた例外をFailureとするPromiseになる
```



## QueueとPromise

Promiseは通常は実行したQueueで実行されます。

別のQueueで実行したい場合は`async`を使います。



```swift
Promise.async{ resolve, reject in
	// 重い処理
	...
	resolve(result)
}
.receive(on: .main) // メインスレッドで受け取る
.sink{ ... } // 実行処理
```



## 特殊なOperator

##### `Combine`

2つ以上のPromiseを組み合わせて全て成功した場合にタプルでOutputを返します。

```swift
let promise1 = Promise(...)
let promise2 = Promise(...)

promise1.combine(promise2)
	.sink{ ... }  // 実行処理
```



##### `CombineCollection`

Promiseの配列を組み合わせて全て成功した場合に配列でOutputを返します。

```swift
let promises = [Promise](...)


promises.combine()
	.sink{ ... }  // 実行処理
```





