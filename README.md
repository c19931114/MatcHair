
# MatcHair
<a href="https://itunes.apple.com/us/app/matchair/id1439561086?l=zh&ls=1&mt=8"><img src="https://i.imgur.com/JBz4hfK.png" width="100"></a> 
1. MatcHair is a C2C sharing platform for hair models and hair designers.

2. MatcHair allows designers to give their works a good exposure, and have more opportunities to improve skills by practicing.
3. Matching by MatcHair, models have more and better choices of hair style, and spend less money changing different kinds of hairstyle.

## Screenshot
![](https://i.imgur.com/yJqt5mU.png) ![](https://i.imgur.com/YqmATw1.png) 
![](https://i.imgur.com/aTQoaDz.png) ![](https://i.imgur.com/d7Z8YUh.png) 
![](https://i.imgur.com/wZhZMnv.png) ![](https://i.imgur.com/WPR5gzt.png)

## Skills

- User can login with Facebook account.
- Use Firebase as back-end database.
- Developed in good coding style with SwiftLint to make code more readable.
- Tracked app crashes by Fabric and Crashlytics.
### ++Parsing Data From Firebase++
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
### ++MVC++
**Take Message Page For Example**
- Model
``` Swift
struct MessageInfo {

    let message: Message
    let user: User
}

struct Message: Codable {

    let fromID: String
    let text: String?
    let timestamp: Int
    let toID: String
}
```
- Controller
``` Swift
// in MessageController
var messageInfo = [MessageInfo]()

override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as? UserCell else {

            return UITableViewCell()
        }

        let messageInfo = messageInfos[indexPath.row]

        // throw data to UserCell
        cell.messageInfo = messageInfo
        
        // coupling below
        // cell.profileImageView.kf.setImage(with: URL(string: messageInfo.user.imageURL))
        // cell.textLabel?.text = messageInfo.user.name
        // cell.detailTextLabel?.text = messageInfo.message.text

        return cell
    }
```
- View
``` Swift
// in UserCell
var messageInfo: MessageInfo? {

    didSet {
    
        if let messageInfo = messageInfo {
            profileImageView.kf.setImage(with: URL(string: messageInfo.user.imageURL))
            textLabel?.text = messageInfo.user.name
            detailTextLabel?.text = messageInfo.message.text  
        }
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


