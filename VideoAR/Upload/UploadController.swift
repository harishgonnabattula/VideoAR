//
//  SecondViewController.swift
//  VideoAR
//
//  Created by Ninja on 11/2/18.
//  Copyright © 2018 Ninja. All rights reserved.
//

import UIKit
import YPImagePicker
import ARKit
import Firebase

class UploadController: UIViewController {

    @IBOutlet weak var upoadVideoButton: UIButton!
    @IBOutlet weak var imageCheck: UIImageView!
    @IBOutlet weak var videoCheck: UIImageView!
    lazy var name = Auth.auth().currentUser?.email?.split(separator: "@").first
    
    private var picker: YPImagePicker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initUploadModule()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    
    @IBAction func imageUpload(_ sender: UIButton) {
        self.view.viewWithTag(99)?.isHidden = true
        pickAndUploadImage()
    }
    
    @IBAction func videoUpload(_ sender: UIButton) {
        self.view.viewWithTag(100)?.isHidden = true
        pickAndUploadVideo()
    }
    
    func initUploadModule() {
        var config = YPImagePickerConfiguration()
        config.library.mediaType = .photoAndVideo
        config.usesFrontCamera = true
        config.showsFilters = false
        config.shouldSaveNewPicturesToAlbum = false
        config.albumName = "TestApp"
        config.screens = [.library, .photo, .video]
        config.startOnScreen = .library
        config.wordings.libraryTitle = "Gallery"
        config.hidesStatusBar = false
        config.library.maxNumberOfItems = 1
        config.library.numberOfItemsInRow = 3
        config.library.spacingBetweenItems = 2
        config.isScrollToChangeModesEnabled = false
        config.library.onlySquare = true
        config.video.compression = AVAssetExportPresetMediumQuality
        // Build a picker with your configuration
        picker = YPImagePicker(configuration: config)
    }
}

// Media Picker helpers
extension UploadController {
    private func pickAndUploadImage() {
        picker?.didFinishPicking { [weak picker] items, _ in
            
            if let photo = items.singlePhoto {
                self.uploadToFirebase(mediaType: .Photo, photo: photo.image)
                self.view.viewWithTag(99)?.isHidden = false
            }
            picker?.dismiss(animated: true, completion: nil)
        }
        present(picker!, animated: true, completion: nil)
    }
    
    private func pickAndUploadVideo() {
        picker?.didFinishPicking { [weak picker] items, _ in
            if let video = items.singleVideo {
                let asset = AVAsset(url: video.url)
                let duration = asset.duration
                let durationTime = CMTimeGetSeconds(duration)
                if durationTime > 60.0 {
                    print("Error. Video greater than 60 sec")
                }
                else {
                    self.uploadToFirebase(mediaType: .Video, vidUrl: video.url)
                    self.view.viewWithTag(100)?.isHidden = false
                }
            }
            picker?.dismiss(animated: true, completion: nil)
        }
        present(picker!, animated: true, completion: nil)
    }
    
    private func uploadToFirebase(mediaType: MediaType, photo: UIImage? = nil, vidUrl: URL? = nil) {
        
        var path = ""
        var data = Data()
        do {
            switch mediaType {
            case .Photo:
                path = self.name! + "/marker.jpg"
                data = photo!.jpegData(compressionQuality: 0.5)!
            case .Video:
                path = self.name! + "/marker.mov"
                data = try Data(contentsOf: vidUrl!)
            }
            
            let hud = AlertHelper.showAlert(of: AlertStatus.Uploading)
            hud.show(in: self.view)
            //Upload Media
            let storage = Storage.storage()
            // Create a root reference
            let storageRef = storage.reference()
            // Create a reference to media
            let markerRef = storageRef.child(path)
            // Upload the file to the path
            let uploadTask = markerRef.putData(data, metadata: nil)
            uploadTask.observe(StorageTaskStatus.success, handler: { (snapshot) in
                hud.dismiss()
                self.upoadVideoButton.isEnabled = true
                print("#############  Media Upload Success   #############")
            })
        }
        catch {
            print("Error in URL")
        }
    }
}
