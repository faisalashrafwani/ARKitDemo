//
//  ViewController.swift
//  ARKitDemo
//
//  Created by admin on 03/08/22.
//

import UIKit
import ARKit

class ViewController: UIViewController,ARSCNViewDelegate {
    
    @IBOutlet weak var draw: UIButton!
    @IBOutlet weak var clear: UIButton!
    @IBOutlet weak var sceneView: ARSCNView!
    
    let configuration = ARWorldTrackingConfiguration() //Add to sceneView to render AR
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions=[ARSCNDebugOptions.showWorldOrigin,ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.showsStatistics=true //DISABLE IT WHEN DISTRIBUTING YOUR APP.
        self.sceneView.session.run(configuration)
        self.sceneView.delegate=self
        
    }
    
    @IBAction func clear(_ sender: Any) {
        self.sceneView.scene.rootNode.enumerateChildNodes { node, _ in
            if node.name == "mark" {
                node.removeFromParentNode()
            }
        }
    }
    
    @IBAction func reset(_ sender: Any) {
        self.sceneView.session.pause()
        self.sceneView.scene.rootNode.enumerateChildNodes { node, _ in
            if node.name == "mark" {
                node.removeFromParentNode()
            }
        }
        self.sceneView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
        
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        guard let pointOfView=sceneView.pointOfView else{return}
        let transform=pointOfView.transform
        //orientation is where my phone is  facing
        let orientation=SCNVector3(-transform.m31,-transform.m32,-transform.m33)
        //where phone is located relative to scene view, transitionally
        let location=SCNVector3(transform.m41,transform.m42,transform.m43)
        
        let currentPositionOfCamera=orientation+location
        
        DispatchQueue.main.async {
            if(self.draw.isHighlighted){
                let sphereNode=SCNNode(geometry:SCNSphere(radius: 0.02))
                sphereNode.position=currentPositionOfCamera
                sphereNode.name = "mark"
                self.sceneView.scene.rootNode.addChildNode(sphereNode)
                sphereNode.geometry?.firstMaterial?.diffuse.contents=UIColor.red
                print("It is highlited")
            }
            else{
                let pointer=SCNNode(geometry:SCNSphere(radius: 0.01))
                pointer.name="pointer"
                pointer.position=currentPositionOfCamera
                self.sceneView.scene.rootNode.enumerateChildNodes({(node,_) in
                    if node.name == "pointer"{
                        node.removeFromParentNode()
                    }
                })
                self.sceneView.scene.rootNode.addChildNode(pointer)
                pointer.geometry?.firstMaterial?.diffuse.contents=UIColor.red
            }
        }
        
    }
    
    
}
//Sums Vectors
func +(left:SCNVector3, right:SCNVector3)-> SCNVector3{
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
    
}
