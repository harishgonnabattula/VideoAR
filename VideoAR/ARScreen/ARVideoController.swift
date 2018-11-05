//
//  FirstViewController.swift
//  VideoAR
//
//  Created by Ninja on 11/2/18.
//  Copyright © 2018 Ninja. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ARVideoController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        //sceneView.automaticallyUpdatesLighting = true
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if ARConfiguration.isSupported {
            // Create a session configuration
            let configuration = ARWorldTrackingConfiguration()
            loadDynamicImageReferences(configuration: configuration)
            // Run the view's session
            sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }
}
    
extension ARVideoController: ARSCNViewDelegate {
    
    /// Create ARReference Images From Somewhere Other Than The Default Folder
    func loadDynamicImageReferences(configuration: ARWorldTrackingConfiguration){
        
        //1. Get The Image From The Folder
        guard let imageUrl = Assests.getImgUrl(),
            let imageFromDirectory = UIImage(contentsOfFile: imageUrl.path),
            //2. Convert It To A CIImage
            let imageToCIImage = CIImage(image: imageFromDirectory),
            //3. Then Convert The CIImage To A CGImage
            let cgImage = convertCIImageToCGImage(inputImage: imageToCIImage)
            
        else {
            return
        }
        
        //4. Create An ARReference Image (Remembering Physical Width Is In Metres)
        let arImage = ARReferenceImage(cgImage, orientation: CGImagePropertyOrientation.up, physicalWidth: 0.3)
        
        //5. Name The Image
        arImage.name = "CGImage Test"
        
        //5. Set The ARWorldTrackingConfiguration Detection Images
        configuration.detectionImages = [arImage]
        
    }
    

    func convertCIImageToCGImage(inputImage: CIImage) -> CGImage? {
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(inputImage, from: inputImage.extent) {
            return cgImage
        }
        return nil
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        //1. Check We Have An ARImageAnchor And Have Detected Our Reference Image
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        
        let referenceImage = imageAnchor.referenceImage
        
        //2. Get The Physical Width & Height Of Our Reference Image
        let width = CGFloat(referenceImage.physicalSize.width)
        let height = CGFloat(referenceImage.physicalSize.height)
        
        //3. Create An SCNNode To Hold Our Video Player With The Same Size As The Image Target
        let videoHolder = SCNNode()
        let videoHolderGeometry = SCNPlane(width: width, height: height)
        videoHolder.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
        videoHolder.geometry = videoHolderGeometry
        
        //4. Create Our Video Player
        if let videoURL = Assests.getVidUrl(){
            
            setupVideoOnNode(videoHolder, fromURL: videoURL)
        }
        
        //5. Add It To The Hierarchy
        node.addChildNode(videoHolder)
    }
    
    func setupVideoOnNode(_ node: SCNNode, fromURL url: URL){
        
        //1. Create An SKVideoNode
        var videoPlayerNode: SKVideoNode!
        
        //2. Create An AVPlayer With Our Video URL
        let videoPlayer = AVPlayer(url: url)
        
        //3. Intialize The Video Node With Our Video Player
        videoPlayerNode = SKVideoNode(avPlayer: videoPlayer)
        videoPlayerNode.yScale = -1
        
        //4. Create A SpriteKitScene & Postion It
        let spriteKitScene = SKScene(size: CGSize(width: 600, height: 300))
        spriteKitScene.scaleMode = .aspectFit
        videoPlayerNode.position = CGPoint(x: spriteKitScene.size.width/2, y: spriteKitScene.size.height/2)
        videoPlayerNode.size = spriteKitScene.size
        spriteKitScene.addChild(videoPlayerNode)
        
        //6. Set The Nodes Geoemtry Diffuse Contenets To Our SpriteKit Scene
        node.geometry?.firstMaterial?.diffuse.contents = spriteKitScene
        
        //5. Play The Video
        videoPlayerNode.play()
        videoPlayer.volume = 1
        
    }
}
