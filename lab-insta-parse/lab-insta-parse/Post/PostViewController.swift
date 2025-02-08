//
//  PostViewController.swift
//  lab-insta-parse
//
//  Created by Charlie Hieger on 11/1/22.
//

import UIKit

// TODO: Import Photos UI
import PhotosUI
import ParseSwift
// TODO: Import Parse Swift

class PostViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var previewImageView: UIImageView!

    private var pickedImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func onPickedImageTapped(_ sender: UIBarButtonItem) {
        // TODO: Pt 1 - Present Image picker
        var config = PHPickerConfiguration()
        config.filter = .images
        config.preferredAssetRepresentationMode = .current
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)

    }

    @IBAction func onShareTapped(_ sender: Any) {

        // Dismiss Keyboard
        view.endEditing(true)
        // TODO: Pt 1 - Create and save Post
        guard let image = pickedImage, //compress the pickedImage for database storing
              let imageData = image.jpegData(compressionQuality: 0.1) else{
            return
        }
        let imageFile = ParseFile(name: "image.jpg", data: imageData)
        
        var post = Post()
        post.imageFile = imageFile //assign compressed image of now time ParseFile to a Post object
        post.caption = captionTextField.text
        post.user = User.current //set post's user to logged in user
        post.save { [weak self] result in
            DispatchQueue.main.async{
                switch result {
                case .success(let post):
                    print("Post Saved! \(post)")
                    //return to previous screen
                    self?.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    self?.showAlert(description: error.localizedDescription)
                }
            }
        }
    } // end onShareTapped

    @IBAction func onViewTapped(_ sender: Any) {
        // Dismiss keyboard
        view.endEditing(true)
    }

    private func showAlert(description: String? = nil) {
        let alertController = UIAlertController(title: "Oops...", message: "\(description ?? "Please try again...")", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}

// TODO: Pt 1 - Add PHPickerViewController delegate and handle picked image.

extension PostViewController: PHPickerViewControllerDelegate{
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else {return}
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            
            guard let image = object as? UIImage else{ //runs if object cannot cast to UIImage
                self?.showAlert()
                return
            }
            
            if let error = error{ //check for and handle errors
                self?.showAlert(description: error.localizedDescription)
                return
            } else { //if there is no error, preview and pick image
                DispatchQueue.main.async {
                    self?.previewImageView.image = image
                    self?.pickedImage = image
                }
            }
        }
    }
    
    
}
