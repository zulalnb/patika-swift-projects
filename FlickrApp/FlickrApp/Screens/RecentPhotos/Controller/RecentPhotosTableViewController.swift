//
//  RecentPhotosTableViewController.swift
//  FlickrApp
//
//  Created by Zülal Nebin on 2.10.2026.
//

import UIKit

class RecentPhotosTableViewController: UITableViewController, UISearchResultsUpdating {
    
    private var response: PhotosResponse? {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
        fetchRecentPhotos()
        
    }
    
    private func setupSearchController(){
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Type something here to search"
        navigationItem.searchController = search
        if #available(iOS 26.0, *) {
            navigationItem.preferredSearchBarPlacement = .stacked
        }
    }
    
    private func fetchRecentPhotos(with search: String? = nil){
        guard let apiKey = ProcessInfo.processInfo.environment["API_KEY"] else { fatalError("API_KEY is missing") }
        
        var components = URLComponents(string: "https://pixabay.com/api")!
        
        components.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "order", value: "latest"),
            URLQueryItem(name: "image_type", value: "photo")
        ]
        
        if let search = search {
            components.queryItems?.append(
                URLQueryItem(name: "q", value: search)
            )
        }
        
        guard let url = components.url else { return }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                debugPrint(error)
                return
            }
            if let data = data, let response = try? JSONDecoder().decode(PhotosResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.response = response
                }
            }
        }.resume()
    }
    
    // MARK: - UITableViewDataSource & UITableViewDelegate
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return response?.hits.count ?? .zero
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let photo = response?.hits[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PhotoTableViewCell
        
        NetworkManager.shared.fetchImage(with: photo?.avatarURL) { data in
            DispatchQueue.main.async {
                cell.ownerImageView.image = UIImage(data: data)
            }
        }
        
        cell.ownerNameLabel.text = photo?.user
        
        NetworkManager.shared.fetchImage(with: photo?.webformatURL) { data in
            DispatchQueue.main.async {
                cell.photoImageView.image = UIImage(data: data)
            }
        }
        
        cell.titleLabel.text = photo?.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let photo = response?.hits[indexPath.row]
        performSegue(withIdentifier: "detailSegue", sender: photo?.id)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let viewController = segue.destination as? PhotoDetailViewController,
           let photoID = sender as? Int {
            viewController.photoID = photoID
        }
    }
    
    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        if text.count > 2 {
            fetchRecentPhotos(with: text)
        }
    }
}

