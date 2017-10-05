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
