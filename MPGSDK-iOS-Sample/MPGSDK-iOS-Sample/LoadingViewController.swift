/*
 Copyright (c) 2017 Mastercard
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import UIKit

public class LoadingViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView?
    
    @IBOutlet weak var titleView: UIView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel?
    
    @IBInspectable let duration: CFTimeInterval = 1.2
    fileprivate let kAnimationKey = "rotation"
    
    public var localizedTitle: String? {
        didSet {
            sync()
        }
    }
    
    public var localizedDescription: String? {
        didSet {
            sync()
        }
    }
    
    public var isActive: Bool {
        get {
            return isBeingPresented || presentingViewController != nil || isBeingDismissed
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        sync()
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        startAnimating()
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        stopAnimating()
    }
    
    fileprivate func sync() {
        titleView?.isHidden = (localizedTitle == nil && localizedDescription == nil)
        titleLabel?.isHidden = (localizedTitle == nil)
        titleLabel?.text = localizedTitle
        descriptionLabel?.isHidden = (localizedDescription == nil)
        descriptionLabel?.text = localizedDescription
    }
    
    public func startAnimating() {
        
        if imageView?.layer.animation(forKey: kAnimationKey) == nil {
            let animate = CABasicAnimation(keyPath: "transform.rotation")
            animate.duration = duration
            animate.repeatCount = Float.infinity
            animate.fromValue = 0.0
            animate.toValue = Double(.pi * 2.0)
            imageView?.layer.add(animate, forKey: kAnimationKey)
        }
    }
    
    public func stopAnimating() {
        imageView?.layer.removeAllAnimations()
    }
}
