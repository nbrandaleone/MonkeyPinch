//
//  ViewController.swift
//  MonkeyPinch
//
//  Created by Nick Brandaleone on 6/3/15.
//  Copyright (c) 2015 Nick Brandaleone. All rights reserved.
//
// This project shows how to use UIGestureRecognizer, both programmatically and using IB.
// Based upon tutorial: http://www.raywenderlich.com/76020/using-uigesturerecognizer-with-swift-tutorial
// I did not implement a custom gesture, only standard ones.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UIGestureRecognizerDelegate {

    var chompPlayer: AVAudioPlayer? = nil
    
    @IBOutlet var monkeyPan: UIPanGestureRecognizer!
    @IBOutlet var bananaPan: UIPanGestureRecognizer!
    
    func loadSound(filename: NSString) -> AVAudioPlayer {
        let url = NSBundle.mainBundle().URLForResource(filename as String, withExtension: "caf")
        var error: NSError? = nil
        let player = AVAudioPlayer(contentsOfURL: url, error: &error)
        if error != nil {
            println("Error loading \(url): \(error?.localizedDescription)")
        } else {
            player.prepareToPlay()
        }
        return player
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        let filteredSubviews = self.view.subviews.filter({
            $0.isKindOfClass(UIImageView)
        })
        
        for view in filteredSubviews {
            let recognizer = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
            recognizer.delegate = self
            view.addGestureRecognizer(recognizer)
            
            recognizer.requireGestureRecognizerToFail(monkeyPan)
            recognizer.requireGestureRecognizerToFail(bananaPan)
        }
        self.chompPlayer = self.loadSound("chomp")
    }
    
    func handleTap(recognizer: UITapGestureRecognizer){
        self.chompPlayer?.play()
    }

    func gestureRecognizer(UIGestureRecognizer,
        shouldRecognizerSimulatenouslyWithGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func handlePan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(self.view)
        if let view = recognizer.view {
            view.center = CGPoint(x: view.center.x + translation.x,
                y: view.center.y + translation.y)
        }
        // must set translation back to zero, or we will get
        // compounded value (error)
        recognizer.setTranslation(CGPointZero, inView: self.view)
        
        if recognizer.state == UIGestureRecognizerState.Ended {
            let velocity = recognizer.velocityInView(self.view)
            let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
            let slideMultiplier = magnitude / 200
            println("magnitude: \(magnitude), slideMultiplier: \(slideMultiplier)")
            
            // If the length is <200 then decrease base speed.
            // Otherwise, increase it. Adjust slideFactor for more of a slide.
            let slideFactor = 0.1 * slideMultiplier
            
            // Calculate final point based upon velocity and slideFactor
            var finalPoint = CGPoint(x: recognizer.view!.center.x + (velocity.x * slideFactor),
                y: recognizer.view!.center.y + (velocity.y * slideFactor))

            // Make sure that the final point is within the view bounds
            finalPoint.x = min(max(finalPoint.x, 0), self.view.bounds.size.width)
            finalPoint.y = min(max(finalPoint.y, 0), self.view.bounds.size.height)
            
            // Animate the view to the final resting place. Use ease-out to slow down at end
            UIView.animateWithDuration(Double(slideFactor*2), delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                recognizer.view!.center = finalPoint
            }, completion: nil)
        }
    }
    
    @IBAction func handlePinch(recognizer: UIPinchGestureRecognizer){
        if let view = recognizer.view {
            view.transform = CGAffineTransformScale(view.transform, recognizer.scale, recognizer.scale)
            recognizer.scale = 1
        }
    }
    
    @IBAction func handleRotate(recognizer: UIRotationGestureRecognizer){
        if let view = recognizer.view {
            view.transform = CGAffineTransformRotate(view.transform, recognizer.rotation)
            recognizer.rotation = 0
        }
    }
}

