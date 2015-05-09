# iOS-333

Welcome to the PartyUp iOS Readme. 

Our code follows the Model-View-Controller design paradigm. All of the views are built using Xcode's interface builder tool, which generates xml for the Main.storyboard file. Each view is linked to a view controller class. These file names all have ViewController as a suffix. The view controllers dictate how to render the information for their associated views and handle user actions. Many of the view controllers implement the UITableViewDelegate protocol, whose methods determine how to populate the cells of a table. The three primary methods of the protocol are:

    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    
When using tableviews, the data for each cell is stored in an array that gets populated using a backend query. Files with the suffix Model (e.g. CreateModel.swift, AlertsModel.swift) function as the middlemen between the front and back end: during the creation processes, the models are staging areas before the user completes the event or group; when fetching data, the models test for errors and null values before passing the information to the view controllers. Here is an function from the CreateModel class that handles inviting friends to an event. This function is called by multiple view controllers:

    func inviteFriendsToEvent(eventID: NSString, userIDs: [NSString]) -> NSString? {
        var backendError: NSString? = PartyUpBackend.instance.backendEventAddFriends(eventID, userIDs: userIDs)
        if backendError == nil {
            return nil
        }
        else {
            return "Invite friends to event failed"
        }
    }

All models call methods of the class PartyUpBackend, a singleton class used for all direct information exchange with the backend. Its one instance is available to all other classes. Each method in this class prepares a dictionary of post parameters which is sent via HTTP request to the server through a method called sendPostRequest(). The sendPostRequest() method converts the returned JSON file from the backend to a dictionary object, which it then returns to the caller. Here is a code excerpt from a method called queryUsers() that fetches the users who match a query search string:

    var postURL: NSString = "http://\(UBUNTU_SERVER_IP)/api/users/search/"
    var postParams: [String: String] = ["username": username! as String, "search": search as String]
    var postData: NSDictionary? = sendPostRequest(postParams, url: postURL)


The DataManager.swift file handles key-value lookups for dictionary objects. All methods of DataManager.swift are static and require an NSDictionary object as a parameter. Here is an example:

    class func getEventInviteList(event: NSDictionary) -> NSArray {
        return event["invite_list"] as! NSArray
    }
    
    
