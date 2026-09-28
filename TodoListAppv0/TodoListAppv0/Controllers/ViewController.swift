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
    
    // Stores a reference to the currently displayed alert.
    // We use it later to access the text entered in its text field.
    var alertController = UIAlertController()
    
    // IBOutlet connects the UITableView from the Storyboard
    // to this property so we can access it in code.
    @IBOutlet weak var tableView: UITableView!
    
    // IBOutlet connects the "Remove All" UIBarButtonItem
    // from the Storyboard to this property.
    // We use it to enable/disable the button depending on whether
    // the data array contains any items.
    @IBOutlet weak var removeBarButtonItem: UIBarButtonItem!
    
    // The data source for our table.
    // The table view will display one row for each item.
    var data = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the ViewController as the table view's delegate.
        // This lets us respond to user interactions and table view events.
        tableView.delegate = self
        
        // Set the ViewController as the table view's data source.
        // This tells the table view where to get its data from.
        tableView.dataSource = self
        
        // Set the initial state of the "Remove All" button.
        // The button should be disabled because the list is initially empty.
        updateRemoveButtonState()
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
    
    // Called when the "Remove All" UIBarButtonItem is tapped.
    @IBAction func didRemoveBarButtonItemTapped(_ sender: UIBarButtonItem) {
        
        // Show a confirmation alert before deleting all items.
        presentAlert(title: "Uyarı!",
                     message: "Listedeki bütün öğeleri silmek istediğinize emin misiniz?",
                     defaultButtonTitle: "Evet",
                     cancelButtonTitle: "Vazgeç") { _ in
            
            // Remove all elements from the data source.
            self.data.removeAll()
            
            // Tell the table view that its data has changed
            // so it can update the visible rows.
            self.tableView.reloadData()
            
            // Update the "Remove All" button because the list is now empty.
            self.updateRemoveButtonState()
        }
        
    }
    
    // Called when the "Add" UIBarButtonItem is tapped.
    @IBAction func didAddBarButtonItemTapped(_ sender: UIBarButtonItem) {
        presentAddAlert()
    }
    
    // Presents an alert that allows the user to enter a new item.
    func presentAddAlert(){
        presentAlert(title: "Yeni Eleman Ekle",
                     message: nil,
                     defaultButtonTitle: "Ekle",
                     cancelButtonTitle: "Vazgeç",
                     isTextFieldAvailable: true,
                     defaultButtonHandler: { _ in
            
            // Get the text entered by the user.
            // The optional chaining (?.) is used because the text field
            // or its text value may be nil.
            //
            // trimmingCharacters removes leading/trailing whitespace
            // and newline characters.
            //
            // ?? "" converts a possible nil value into an empty String.
            let text = self.alertController.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            
            // Only add the item if the resulting text is not empty.
            if !text.isEmpty {
                
                // Add the new item to the data source.
                self.data.append(text)
                
                // Refresh the table view so the newly added item appears.
                self.tableView.reloadData()
                
                // Enable the "Remove All" button because the list
                // now contains at least one item.
                self.updateRemoveButtonState()
                
            } else {
                // If the user entered an empty value,
                // show a warning instead of adding it to the list.
                self.presentWarningAlert()
                
            }
        })
    }
    
    // Shows a warning alert when the user tries to add an empty item.
    func presentWarningAlert(){
        presentAlert(title: "Uyarı!",
                     message: "Liste elemanı boş olamaz.",
                     cancelButtonTitle: "Tamam")
    }
    
    // A reusable helper method for creating and presenting UIAlertControllers.
    // This prevents us from repeating the same alert creation code
    // in different places.
    func presentAlert(title: String?,
                      message: String?,
                      preferredStyle: UIAlertController.Style = .alert,
                      defaultButtonTitle: String? = nil,
                      cancelButtonTitle: String?,
                      isTextFieldAvailable: Bool = false,
                      defaultButtonHandler: ((UIAlertAction) -> Void)? = nil
    ){
        
        // Create a new UIAlertController with the provided configuration.
        alertController = UIAlertController(title: title,
                                            message: message,
                                            preferredStyle: preferredStyle)
        
        // Add the default/action button only if a title was provided.
        if defaultButtonTitle != nil {
            
            // Create the action and assign the provided handler.
            // The handler is executed when the user taps this button.
            let defaultButton = UIAlertAction(title: defaultButtonTitle,
                                              style: .default,
                                              handler: defaultButtonHandler)
            alertController.addAction(defaultButton)
        }
        
        // Create a cancel button.
        let cancelButton = UIAlertAction(title: cancelButtonTitle,
                                         style: .cancel)
        
        
        // Add a text field only when the caller requests one.
        if isTextFieldAvailable {
            alertController.addTextField()
        }
        
        // Add the cancel button to the alert.
        alertController.addAction(cancelButton)
        
        // Present the alert controller on the screen.
        present(alertController, animated: true)
    }
    
    
    // Updates the enabled/disabled state of the "Remove All" button
    // according to whether the data array contains any items.
    func updateRemoveButtonState() {
        // isEnabled expects a Boolean value.
        //
        // data.isEmpty == true  → !true  == false → button disabled
        // data.isEmpty == false → !false == true  → button enabled
        removeBarButtonItem.isEnabled = !data.isEmpty
    }
}

