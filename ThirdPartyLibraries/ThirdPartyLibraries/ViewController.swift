//
//  ViewController.swift
//  AdvancedSwift
//
//  Created by Zülal Nebin on 1.10.2026.
//

import UIKit
import Alamofire
import SnapKit
import Kingfisher
import FLEX

class ViewController: UIViewController {
    
    @IBOutlet weak var redView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = UIImage(resource: .roseBlue)
        
    }
    
    // MARK: - Kingfisher
    func setImageViaKingfisher() {
        imageView.kf.setImage(with: URL(string: "https://cdn.pixabay.com/photo/2015/04/19/08/32/marguerite-729510__480.jpg"))
    }
    
    func setImageViaAlamoFire() {
        let url = URL(string: "https://cdn.pixabay.com/photo/2015/04/19/08/32/marguerite-729510__480.jpg")
        
        let cache = NSCache<AnyObject, AnyObject>()
        
        if let imageFromCache = cache.object(forKey: url as AnyObject) as? UIImage {
            imageView.image = imageFromCache
            return
        }
        
        AF.request(url!, method: .get).response { response in
            switch response.result {
            case .failure(let error):
                print(error)
            case .success(let data):
                guard let data = data,
                      let image = UIImage(data: data) else {
                    return
                }
                cache.setObject(image, forKey: url as AnyObject)
                self.imageView.image = image
            }
        }
    }
    
    // MARK: - Snapkit
    func setConstraintsViaSnapKit() {
        redView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(128.0)
            make.width.equalTo(256.0)
        }
    }
    
    func setConstraintsViaAutoLayout() {
        redView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            redView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            redView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            redView.heightAnchor.constraint(equalToConstant: 128.0),
            redView.widthAnchor.constraint(equalToConstant: 256.0)
        ])
    }
    
    // MARK: - Alamofire
    func fetchWithAlamoFire() {
        AF.request("https://httpbin.org/get").response { response in
            debugPrint(response)
        }
    }
    
    func fetchWithURLSession() {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")
        let request = URLRequest(url: url!)

        let task = URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else { return }
            print(String(data: data, encoding: .utf8) ?? "Data not found or not in correct format.")
        }
        
        task.resume()
    }
}
