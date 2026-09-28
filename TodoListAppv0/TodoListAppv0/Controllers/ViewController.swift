//
//  ViewController.swift
//  TodoListAppv0
//
//  Created by Zülal Nebin on 27.09.2026.
//

import UIKit
import CoreData

// ViewController manages the screen and coordinates
// the table view with the Core Data persistence layer.
class ViewController: UIViewController {
    
    // Keeps a reference to the currently displayed alert.
    // We use it later to access the text entered in its text field.
    var alertController = UIAlertController()
    
    // Connects the UITableView from the Storyboard
    // to this property so we can access it in code.
    @IBOutlet weak var tableView: UITableView!
    
    // Connects the "Remove All" UIBarButtonItem from the Storyboard.
    // Its enabled state depends on whether the list contains any items.
    @IBOutlet weak var removeBarButtonItem: UIBarButtonItem!
    
    // Holds the ListItem managed objects fetched from Core Data.
    // Each object represents one item stored in the persistent store.
    var data = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the ViewController as the table view's delegate.
        // The delegate handles table view events and user interactions.
        tableView.delegate = self
        
        // Set the ViewController as the table view's data source.
        // The data source provides the content displayed by the table view.
        tableView.dataSource = self
        
        // Fetch the existing ListItem objects from Core Data
        // when the screen is loaded.
        fetch()
    }
    
    
    // Called when the "Remove All" UIBarButtonItem is tapped.
    @IBAction func didRemoveBarButtonItemTapped(_ sender: UIBarButtonItem) {
        
        // Ask the user for confirmation before deleting all items.
        presentAlert(title: "Uyarı!",
                     message: "Listedeki bütün öğeleri silmek istediğinize emin misiniz?",
                     defaultButtonTitle: "Evet",
                     cancelButtonTitle: "Vazgeç") { _ in
            
            // Get the Core Data managed object context.
            // The context is responsible for managing Core Data objects
            // and communicating changes to the persistent store.
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let managedObjectContext = appDelegate?.persistentContainer.viewContext
            
            // Create a fetch request for all ListItem objects.
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(
                entityName: "ListItem"
            )
            
            // Create a batch delete request.
            // This allows all matching ListItem objects to be deleted
            // in a single Core Data operation.
            let deleteRequest = NSBatchDeleteRequest(
                fetchRequest: fetchRequest
            )
            
            // Execute the batch delete request.
            // Unlike context.delete(), a batch delete operates directly
            // on the persistent store, so context.save() is not required here.
            try! managedObjectContext!.execute(deleteRequest)
            
            // Fetch the updated data and refresh the table view.
            self.fetch()
        }
        
    }
    
    // Called when the "Add" UIBarButtonItem is tapped.
    @IBAction func didAddBarButtonItemTapped(_ sender: UIBarButtonItem) {
        presentAddAlert()
    }
    
    // Presents an alert that allows the user to enter a new item.
    func presentAddAlert() {
        presentAlert(
            title: "Yeni Eleman Ekle",
            message: nil,
            defaultButtonTitle: "Ekle",
            cancelButtonTitle: "Vazgeç",
            isTextFieldAvailable: true,
            defaultButtonHandler: { _ in
                
                // Get and trim the text entered by the user.
                //
                // Optional chaining (?.) is used because the text field
                // or its text value may be nil.
                //
                // ?? "" provides an empty String when the value is nil.
                let text = self.alertController.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                
                // Only create a Core Data object if the entered text is not empty.
                if !text.isEmpty {
                    
                    // Get the Core Data managed object context.
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    let managedObjectContext = appDelegate?.persistentContainer.viewContext
                    
                    // Get the ListItem entity description.
                    // The entity name must match the entity defined in the
                    // Core Data model.
                    let entity = NSEntityDescription.entity(forEntityName: "ListItem",
                                                            in: managedObjectContext!)
                    
                    // Create a new managed object for the ListItem entity.
                    // The new object is inserted into the managed object context.
                    let listItem = NSManagedObject(entity: entity!,
                                                   insertInto: managedObjectContext)
                    
                    // Set the title attribute of the new Core Data object.
                    listItem.setValue(text, forKey: "title")
                    
                    // Save the new object to persistent storage.
                    try? managedObjectContext?.save()
                    
                    // Fetch the updated data and refresh the table view.
                    self.fetch()
                } else {
                    
                    // Do not create an empty Core Data object.
                    // Show a warning instead.
                    self.presentWarningAlert()
                    
                }
            }
        )
    }
    
    // Shows a warning alert when the user tries to add an empty item.
    func presentWarningAlert(){
        presentAlert(title: "Uyarı!",
                     message: "Liste elemanı boş olamaz.",
                     cancelButtonTitle: "Tamam")
    }
    
    // A reusable helper for creating and presenting alerts.
    // This keeps the alert creation logic in one place.
    func presentAlert(
        title: String?,
        message: String?,
        preferredStyle: UIAlertController.Style = .alert,
        defaultButtonTitle: String? = nil,
        cancelButtonTitle: String?,
        isTextFieldAvailable: Bool = false,
        textFieldInitialValue: String? = nil,
        defaultButtonHandler: ((UIAlertAction) -> Void)? = nil
    ) {
        
        // Create a new alert controller with the provided configuration.
        alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: preferredStyle
        )
        
        // Add the primary action only when a title is provided.
        if defaultButtonTitle != nil {
            
            // The handler is executed when the user taps the action.
            let defaultButton = UIAlertAction(
                title: defaultButtonTitle,
                style: .default,
                handler: defaultButtonHandler
            )
            
            alertController.addAction(defaultButton)
        }
        
        // Create the cancel action.
        let cancelButton = UIAlertAction(
            title: cancelButtonTitle,
            style: .cancel
        )
        
        // Add a text field only when requested by the caller.
        if isTextFieldAvailable {
            
            // Configure the text field when it is created.
            // textFieldInitialValue allows the caller to provide
            // an initial value, which is useful when editing an item.
            alertController.addTextField { textField in
                textField.text = textFieldInitialValue
            }
        }
        
        // Add the cancel action to the alert.
        alertController.addAction(cancelButton)
        
        // Present the configured alert on the screen.
        present(alertController, animated: true)
    }
    
    // Fetches ListItem objects from Core Data and updates the UI.
    func fetch(){
        
        // Get the Core Data managed object context.
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedObjectContext = appDelegate?.persistentContainer.viewContext
        
        // Create a fetch request for ListItem entities.
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ListItem")
        
        // Execute the fetch request and store the resulting
        // managed objects in the data array.
        data = try! managedObjectContext!.fetch(fetchRequest)
        
        // Refresh the table view using the newly fetched data.
        tableView.reloadData()
        
        // Enable the "Remove All" button only when
        // at least one Core Data object exists.
        removeBarButtonItem.isEnabled = !data.isEmpty
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

// Keeps the table view-related methods separate from the main
// ViewController implementation.
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    // Tells the table view how many rows it should display.
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        
        // The number of rows must match the number of items
        // available in the data source.
        return data.count
    }
    
    // Provides and configures the cell for a specific row.
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        // UITableView reuses cells instead of creating a new cell
        // for every row. This improves memory usage and performance.
        //
        // "defaultCell" must match the cell's Reuse Identifier
        // configured in the Storyboard.
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "defaultCell",
            for: indexPath
        )
        
        // Get the Core Data managed object corresponding to this row.
        let listItem = data[indexPath.row]
        
        // Read the "title" attribute from the managed object.
        // value(forKey:) returns Any?, so it must be cast to String.
        cell.textLabel?.text = listItem.value(forKey: "title") as? String
        
        // Return the configured reusable cell to the table view.
        return cell
        
    }
    
    
    // Provides swipe actions for each table view row.
    // These actions allow the user to delete or edit an item.
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        
        // MARK: Delete
        
        // Create the delete swipe action.
        let deleteAction = UIContextualAction(
            style: .normal,
            title: "Sil"
        ) { _, _, _ in
            
            // Get the Core Data managed object context.
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let managedObjectContext = appDelegate?.persistentContainer.viewContext
            
            // Delete the selected managed object from the context.
            managedObjectContext?.delete(self.data[indexPath.row])
            
            // Persist the deletion to Core Data.
            try? managedObjectContext?.save()
            
            // Fetch the updated data and refresh the table view.
            self.fetch()
        }
        
        // Give the delete action a system red background.
        deleteAction.backgroundColor = .systemRed
        
        // MARK: Edit
        
        // Create the edit swipe action.
        let editAction = UIContextualAction(
            style: .normal,
            title: "Düzenle"
        ) { _, _, _ in
            
            // Get the managed object corresponding to the selected row.
            let listItem = self.data[indexPath.row]
            
            // Get the Core Data managed object context.
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let managedObjectContext = appDelegate?.persistentContainer.viewContext
            
            // Show the edit alert and pre-fill the text field
            // with the current "title" value.
            self.presentAlert(
                title: "Elemanı Düzenle",
                message: nil,
                defaultButtonTitle: "Düzenle",
                cancelButtonTitle: "Vazgeç",
                isTextFieldAvailable: true,
                textFieldInitialValue: listItem.value(forKey: "title") as? String,
                defaultButtonHandler: { _ in
                    
                    // Get and trim the edited text.
                    // ?? "" converts a possible nil value into
                    // an empty String.
                    let text = self.alertController.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    
                    // Only update the item if the new value is not empty.
                    if !text.isEmpty {
                        
                        // Update the "title" attribute of the managed object.
                        self.data[indexPath.row].setValue(text, forKey: "title")
                        
                        // Check whether the context contains unsaved changes.
                        if managedObjectContext!.hasChanges {
                            try? managedObjectContext?.save()
                        }
                        
                        // Refresh the table view to display the updated value.
                        self.tableView.reloadData()
                        
                    } else {
                        
                        // Do not replace the existing value with an empty string.
                        self.presentWarningAlert()
                    }
                }
            )
        }
        
        // Combine the available swipe actions into one configuration.
        let config = UISwipeActionsConfiguration(
            actions: [deleteAction, editAction]
        )
        
        // Return the configuration to the table view.
        return config
    }
}
