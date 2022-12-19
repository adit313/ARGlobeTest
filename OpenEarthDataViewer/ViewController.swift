//
//  ViewController.swift
//  OpenEarthDataViewer
//
//  Created by Adit Patel on 12/19/22.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        let earthNode = SCNNode()
        earthNode.geometry = SCNSphere(radius: 0.25)
        earthNode.position = SCNVector3(x: 0, y: 0, z: -0.5)
        scene.rootNode.addChildNode(earthNode)
        let mat = SCNMaterial()
        mat.diffuse.contents = UIImage(named: "art.scnassets/earth_color_10K.tif")
        earthNode.geometry?.materials = [mat]
        
        let earthData = SCNNode()
        earthData.geometry = SCNPlane(width: 0.0772, height: 0.0611)
        earthData.position = SCNVector3(x: 0, y: 0.4, z: -0.5)
        scene.rootNode.addChildNode(earthData)
        let earthDataMat = SCNMaterial()
        earthDataMat.diffuse.contents = UIImage(named: "earth_data")!
        earthData.geometry?.materials = [earthDataMat]
        
        let americaData = SCNNode()
        americaData.geometry = SCNPlane(width: 0.2256, height: 0.133)
        americaData.position = SCNVector3(x: -0.4, y: 0.15, z: 0)
        americaData.rotation = SCNVector4(x: Float(CGFloat(2 * Double.pi)), y: Float(CGFloat(2 * Double.pi)), z: 0, w: 0)
        earthNode.addChildNode(americaData)
        let americaDataMat = SCNMaterial()
        americaDataMat.diffuse.contents = UIImage(named: "america_data")!
        americaData.geometry?.materials = [americaDataMat]
        americaData.light?.doubleSided = true
        
        let globalDataLine = lineBetweenNodeA(nodeA: earthNode, nodeB: earthData)
        scene.rootNode.addChildNode(globalDataLine)
        
        let americaDataLine = lineBetweenNodeA(nodeA: earthNode, nodeB: americaData)
        earthNode.addChildNode(americaDataLine)

        
        let spin = CABasicAnimation(keyPath: "rotation")
        // Use from-to to explicitly make a full rotation around z
        spin.fromValue = NSValue(scnVector4: SCNVector4(x: 0, y: 1, z: 0, w: 0))
        spin.toValue = NSValue(scnVector4: SCNVector4(x: 0, y: 1, z: 0, w: Float(CGFloat(2 * Double.pi))))
        spin.duration = 300
        spin.repeatCount = .infinity
        earthNode.addAnimation(spin, forKey: "spin around")
        
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if(touch.view == self.sceneView){
                //print("touch working")
                let viewTouchLocation:CGPoint = touch.location(in: sceneView)
                guard let result = sceneView.hitTest(viewTouchLocation, options: nil).first else {
                    return
                }
                print(result)
            }
        }
    }
    
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func lineBetweenNodeA(nodeA: SCNNode, nodeB: SCNNode) -> SCNNode {
        let positions: [Float32] = [nodeA.position.x, nodeA.position.y, nodeA.position.z, nodeB.position.x, nodeB.position.y, nodeB.position.z]
        let positionData = NSData(bytes: positions, length: MemoryLayout<Float32>.size*positions.count)
        let indices: [Int32] = [0, 1]
        let indexData = NSData(bytes: indices, length: MemoryLayout<Int32>.size * indices.count)
        
        let source = SCNGeometrySource(data: positionData as Data, semantic: SCNGeometrySource.Semantic.vertex, vectorCount: indices.count, usesFloatComponents: true, componentsPerVector: 3, bytesPerComponent: MemoryLayout<Float32>.size, dataOffset: 0, dataStride: MemoryLayout<Float32>.size * 3)
        let element = SCNGeometryElement(data: indexData as Data, primitiveType: SCNGeometryPrimitiveType.line, primitiveCount: indices.count, bytesPerIndex: MemoryLayout<Int32>.size)
        
        let line = SCNGeometry(sources: [source], elements: [element])
        return SCNNode(geometry: line)
    }
}
