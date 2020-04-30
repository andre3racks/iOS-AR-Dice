//
//  ViewController.swift
//  ARDice
//
//  Created by Andreas Anglin on 2020-02-05.
//  Copyright © 2020 Andreas Anglin. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var diceArray = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        
        
        
        sceneView.autoenablesDefaultLighting = true
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // horizontal place detection
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    @IBAction func removeDice(_ sender: UIBarButtonItem) {
        
        if !diceArray.isEmpty   {
            for dice in diceArray   {
                dice.removeFromParentNode()
            }
        }
    }
    @IBAction func rollAll(_ sender: UIBarButtonItem) {
        rollDice()
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollDice()
    }
    
    // method for detecting touch screen for 3d space
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first    {
            
            let touchLocation = touch.location(in: sceneView)
            
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResults = results.first   {
                
                //add dice to scene
                let diceScene = SCNScene(named: "art.scnassets/diceCollada copy.scn")!
                
                if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
                
                    diceNode.position = SCNVector3(x: hitResults.worldTransform.columns.3.x,
                                                   y: hitResults.worldTransform.columns.3.y,
                                                   z: hitResults.worldTransform.columns.3.z)
                
                    diceArray.append(diceNode)
                    
                    roll(dice: diceNode)
                    
                    sceneView.scene.rootNode.addChildNode(diceNode)
                        // Set the scene to the view
                
                    
                    }
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    
        if anchor is ARPlaneAnchor  {
            let planeAnchor = anchor as! ARPlaneAnchor
            
            //create scene plane for this anchor
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            
            //create node for plane
            let planeNode = SCNNode()
            
            planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
            
            //transform plane to make horizontal around x axis
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            
            let grid = SCNMaterial()
            grid.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            
            plane.materials = [grid]
            
            planeNode.geometry = plane
            
            node.addChildNode(planeNode)
        }
        else{
            print("not horizontal")
        }
    }
    
    func rollDice() {
        if !diceArray.isEmpty {
            for dice in diceArray   {
                roll(dice: dice)
            }
        }
    }
    
    func roll(dice: SCNNode) {
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        
        dice.runAction(
            SCNAction.rotateBy(
                x: CGFloat(randomX * 5),
                y: 0,
                z: CGFloat(randomZ * 5),
                duration: 2)
        )
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
