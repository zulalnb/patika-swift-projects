//
//  PhotoDetailViewController.swift
//  FlickrApp
//
//  Created by Zülal Nebin on 3.10.2026.
//

import UIKit

class PhotoDetailViewController: UIViewController {
    
    var photoID: Int?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var ownerImageView: UIImageView!
    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Photo Detail"
        imageView.backgroundColor = .gray
        ownerImageView.backgroundColor = .darkGray
        ownerImageView.layer.cornerRadius = 24.0
        ownerNameLabel.text = "Owner Name"
        descriptionLabel.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam ut."
        
        guard let photoID else { return }
        
        fetchPhotoDetail(with: photoID)
        
    }
    
    private func fetchPhotoDetail(with id: Int){
        guard let apiKey = ProcessInfo.processInfo.environment["API_KEY"] else { fatalError("API_KEY is missing") }
        
        var components = URLComponents(string: "https://pixabay.com/api")!
        
        components.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "order", value: "latest"),
            URLQueryItem(name: "image_type", value: "photo"),
            URLQueryItem(name: "id", value: String(id))
        ]
        
        guard let url = components.url else { return }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                debugPrint(error)
                return
            }
            if let data = data, let response = try? JSONDecoder().decode(PhotosResponse.self, from: data) {
                DispatchQueue.main.async {
                    guard let photo = response.hits.first else { return }
                    self.configure(with: photo)
                }
            }
            
        }.resume()
    }
    
    private func configure(with photo: Photo) {
        
        ownerNameLabel.text = photo.user
        descriptionLabel.text = photo.tags
        title = photo.name

        NetworkManager.shared.fetchImage(with: photo.avatarURL) { data in
            self.ownerImageView.image = UIImage(data: data)
            self.ownerImageView.backgroundColor = .clear
        }

        NetworkManager.shared.fetchImage(with: photo.largeImageURL) { data in
            self.imageView.image = UIImage(data: data)
            self.imageView.backgroundColor = .clear

        }
    }
}

