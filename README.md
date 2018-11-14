# MatcHair

<a href="https://itunes.apple.com/us/app/matchair/id1439561086?l=zh&ls=1&mt=8"><img src="https://i.imgur.com/JBz4hfK.png" width="100"></a> **<-- Click to Download in App Store**

1. MatcHair is a C2C sharing platform for hair models and hair designers.

2. MatcHair allows designers to give their works a good exposure, and have more opportunities to improve skills by practicing.
3. Matching by MatcHair, models have more and better choices of hair style, and spend less money changing different kinds of hairstyle.

## Screenshots
![](https://i.imgur.com/7wp1iuF.png)


## Skills

- User can login with Facebook account.
- Use Firebase as back-end database.
- Implement MVC design pattern in some case.
- Developed in good coding style with SwiftLint to make code more readable.
- Tracked app crashes by Fabric and Crashlytics.

### Parsing Data From Firebase
**Take Chat Log For Example**

- Create message model with Codable.

``` Swift
struct Message: Codable {

    let fromID: String
    let text: String?
    let timestamp: Int
    let toID: String
}
```

- Observe messages data from firebase, and downcast snapshot value to NSDictionary.
``` Swift
import Firebase
```
``` Swift
Database.database().reference()
    .child("file path")
        .observeSingleEvent(of: .value) { (snapshot) in
        // the type of snapshot is (DataSnapshot)
        
        // top level object of JSON write is an NSArray or NSDictionary
        guard let value = snapshot.value as? NSDictionary else {
            return
        }
        
        // serialize data to JSON 
        guard let messageJSONData = try? JSONSerialization.data(withJSONObject: value) else { return }
}
```

- Parse JSON data with codable model, and use a do-catch statement to handle errors by decoding JSON data.

``` Swift
let decoder = JSONDecoder()
```

``` Swift
do {
    // decode Message
    let messageData = try self.decoder.decode(Message.self, from: messageJSONData) 
} catch {
    // print error message if fail to decode
    print(error)
}
```
### MVC

#### Take Post Page For Example
![](https://i.imgur.com/rRCpp7n.png)

- Add Protocol
``` Swift
protocol CategoryProtocol: AnyObject {
    // throw data to PostViewController
    func sendCategory(data: [String: Bool])
}
```
- Create a Delegate Property
``` Swift
// in CategoryTableViewCell
weak var categoryDelegate: CategoryProtocol?
```
- Conform to Protocol
``` Swift
// in PostViewController
PostViewController: UIViewController, CategoryProtocol {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = recruitTableView.dequeueReusableCell(
                withIdentifier: String(describing: CategoryTableViewCell.self),
                for: indexPath)

        guard let categoryCell = cell as? CategoryTableViewCell else {
                return cell
        }
        
        // add the delegate method call
        categoryCell.categoryDelegate = self

        return categoryCell
    }
    
    // conform the protocol
    func sendCategory(data: [String: Bool]) {
        // add any implementation inside it
    }
}
```



## Library

- SwiftLint
- KingFisher
- lottie-ios
- IQKeyboardManagerSwift
- Fabric
- Crashlytics
- Firebase/Core


