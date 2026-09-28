//
//  ViewController.swift
//  TodoListAppv0
//
//  Created by Zülal Nebin on 27.09.2026.
//

import UIKit

// ViewController manages the screen.
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
    
    // The source of truth for the table view's content.
    // Each String represents one row in the list.
    var data = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the ViewController as the table view's delegate.
        // The delegate handles table view events and user interactions.
        tableView.delegate = self
        
        // Set the ViewController as the table view's data source.
        // The data source provides the content displayed by the table view.
        tableView.dataSource = self
        
        // Set the initial state of the "Remove All" button.
        // The list is initially empty, so the button should be disabled.
        updateRemoveButtonState()
    }
    
    
    // Called when the "Remove All" UIBarButtonItem is tapped.
    @IBAction func didRemoveBarButtonItemTapped(_ sender: UIBarButtonItem) {
        
        // Ask the user for confirmation before deleting all items.
        presentAlert(title: "Uyarı!",
                     message: "Listedeki bütün öğeleri silmek istediğinize emin misiniz?",
                     defaultButtonTitle: "Evet",
                     cancelButtonTitle: "Vazgeç") { _ in
            
            // Remove all elements from the data source.
            self.data.removeAll()
            
            // Refresh the table view because its data source has changed.
            self.tableView.reloadData()
            
            // Update the button because the list is now empty.
            self.updateRemoveButtonState()
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
                
                // Only add the item if the resulting text is not empty.
                if !text.isEmpty {
                    // Add the new item to the data source.
                    self.data.append(text)
                    
                    // Refresh the table view so the new item appears.
                    self.tableView.reloadData()
                    
                    // Enable the "Remove All" button because
                    // the list now contains at least one item.
                    self.updateRemoveButtonState()
                } else {
                    
                    // Do not add empty items.
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

        // indexPath.row identifies the current row.
        // Use it to retrieve the corresponding item from the data array.
        cell.textLabel?.text = data[indexPath.row]

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

            // Remove the item at the selected row from the data source.
            self.data.remove(at: indexPath.row)

            // Refresh the table view after modifying the data source.
            tableView.reloadData()

            // Disable the "Remove All" button if the list became empty.
            self.updateRemoveButtonState()
        }

        // Give the delete action a system red background.
        deleteAction.backgroundColor = .systemRed

        // MARK: Edit
        // Create the edit swipe action.
        let editAction = UIContextualAction(
            style: .normal,
            title: "Düzenle"
        ) { _, _, _ in

            // Show the edit alert and pre-fill the text field
            // with the current value of the selected item.
            self.presentAlert(
                title: "Elemanı Düzenle",
                message: nil,
                defaultButtonTitle: "Düzenle",
                cancelButtonTitle: "Vazgeç",
                isTextFieldAvailable: true,
                textFieldInitialValue: self.data[indexPath.row],
                defaultButtonHandler: { _ in

                    // Get and trim the edited text.
                    // ?? "" converts a possible nil value into
                    // an empty String.
                    let text = self.alertController.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

                    // Only update the item if the new value is not empty.
                    if !text.isEmpty {

                        // Replace the old value at the selected index.
                        self.data[indexPath.row] = text
                        
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
