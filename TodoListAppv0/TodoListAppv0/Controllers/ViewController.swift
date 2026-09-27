//
//  ViewController.swift
//  TodoListAppv0
//
//  Created by Zülal Nebin on 27.09.2026.
//

import UIKit

// ViewController manages the screen and conforms to
// UITableViewDelegate and UITableViewDataSource protocols.
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // IBOutlet connects the UITableView from the Storyboard
    // to this property so we can access it in code.
    @IBOutlet weak var tableView: UITableView!
    
    // The data source for our table.
    // The table view will display one row for each item.
    let data = ["Swift", "Kotlin", "C++", "C", "Python", "Java", "C#"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the ViewController as the table view's delegate.
        // This lets us respond to user interactions and table view events.
        tableView.delegate = self
        
        // Set the ViewController as the table view's data source.
        // This tells the table view where to get its data from.
        tableView.dataSource = self
    }

    // Tells the table view how many rows it should display.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // The number of rows should match the number of items in our data array.
        return data.count
    }
    
    // Provides a cell for each row.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // ❌ Do not create a new cell for every row:
        // let cell = UITableViewCell()
        //
        // Creating a new cell every time is inefficient because it creates
        // a new object for every row instead of reusing existing cells.
        //
        // UITableView is designed to reuse cells that have scrolled off-screen.
        // This is especially important when displaying a large amount of data.

        // ✅ Reuse an existing cell whenever possible.
        // "defaultCell" must match the cell's Reuse Identifier
        // configured in the Storyboard.
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
        
        // indexPath.row tells us which row is currently being requested.
        // Use it to get the corresponding item from the data array.
        cell.textLabel?.text = data[indexPath.row]
        
        // Return the configured cell to the table view.
        return cell
    }
}

