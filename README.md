iOS Client for Share.js
========================

Still work in progress.

Todo list
---------

* Write tests (switch to TDD)
* Create classes for all JSON operations
* Make a queing system for sending messages via the socket
* Saving unsended operations / send them when we are online again
* More universal way to apply Operations; 
	* The are designed for nsdictionary/nsarray's now
	* Create a protocol (SHOperationTarget?)


Example
--------

	NSURL *url = [NSURL URLWithString:@"ws://localhost:8000/sockjs/websocket"];
	SHJSONClient *client = [[SHJSONClient alloc] initWithURL:url docName:@"groceries"];

	NSMutableArray __block *groceries = [@[ @"milk", @"bread", @"eggs" ] mutableCopy];

	[client addCallback:^(SHType type, id<SHOperation> operation) {

		// add the remote grocerie to our groceries array.
		[operation runOnObject:&groceries];

	} forPath:[SHPath pathWithKeyPath:@"list.items"] type:SHTypeInsertItemToList];