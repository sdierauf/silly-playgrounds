//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport


// returns a random color
func randomColor() -> UIColor{
    let red = CGFloat(drand48())
    let green = CGFloat(drand48())
    let blue = CGFloat(drand48())
    return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
}


public class BallPit: UIView {
    
    private var balls: [UIView] = []
    private var animator: UIDynamicAnimator?
    public let collisionBehavior: UICollisionBehavior
    public let gravityBehavior: UIGravityBehavior
    public let itemBehavior: UIDynamicItemBehavior
    private var snapBehavior: UISnapBehavior?
    private var gravityButton: UIButton
    private var loggerButton: UIButton // add button for logging current state
    private var testView: UIView
    public var gravityOn: Bool
    private var ballSizeSlider: UISlider
    
    let width = 320 * 2 //dat retina
    let height = 480 * 2
    
    public init(numBalls: Int) {
        collisionBehavior = UICollisionBehavior(items: [])
        gravityBehavior = UIGravityBehavior(items: [])
        itemBehavior = UIDynamicItemBehavior(items: [])
        gravityButton = UIButton.init(type: UIButtonType.roundedRect)
        ballSizeSlider = UISlider.init()
        loggerButton = UIButton.init(type: UIButtonType.roundedRect)
        testView = UIView(frame: CGRect.zero)
        gravityOn = false
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        backgroundColor = UIColor.white()
        
        animator = UIDynamicAnimator(referenceView: self)
        animator?.addBehavior(collisionBehavior)
        animator?.addBehavior(gravityBehavior)
        animator?.addBehavior(itemBehavior)

        setUpGravityButton()
        setUpBallSizeSlider()
        setUpLogger()
        
        // test view do something??
        addSubview(testView)
        testView.frame = CGRect(x: 10, y: 10, width: 50, height: 50)
        testView.backgroundColor = UIColor.blue()
        collisionBehavior.addItem(testView)
        itemBehavior.addItem(testView)
        
        createBallViews(numBalls: numBalls)
        createPit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpLogger() {
        addSubview(loggerButton)
        loggerButton.frame = CGRect(x: 100, y: 60, width: 50, height: 40)
        let loggerButtonTitle:AttributedString = AttributedString(string: "Log", attributes:
            [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 25)])
        loggerButton.setAttributedTitle(loggerButtonTitle, for: UIControlState.normal)
        loggerButton.addTarget(nil, action: #selector(logBallInfo), for: UIControlEvents.touchUpInside)
        collisionBehavior.addItem(loggerButton)
        itemBehavior.addItem(loggerButton)
    }
    
    @IBAction func logBallInfo() {
        for ball in balls {
            NSLog(ball.frame.debugDescription)
        }
    }
    
    func setUpGravityButton() {
        addSubview(gravityButton)
        gravityButton.frame = CGRect(x: 100, y: 30, width: 100, height: 40)
        gravityButton.setTitle("Gravity", for: UIControlState.normal)
        let gravityButtonTitle: AttributedString = AttributedString(string: "Gravity", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 25)])
        gravityButton.setAttributedTitle(gravityButtonTitle, for: UIControlState.normal)
        gravityButton.setTitleColor(UIColor.blue(), for: UIControlState.normal)
        gravityButton.addTarget(nil, action: #selector(self.toggleGravity), for: UIControlEvents.touchUpInside)
        
        // Make it interact
        collisionBehavior.addItem(gravityButton)
        itemBehavior.addItem(gravityButton)
    }
    
    func setUpBallSizeSlider() {
        addSubview(ballSizeSlider)
        ballSizeSlider.frame = CGRect(x: 300, y: 30, width: 300, height: 40)
        ballSizeSlider.isContinuous = true
        ballSizeSlider.minimumValue = 5
        ballSizeSlider.maximumValue = 60
        ballSizeSlider.value = 50
        ballSizeSlider.addTarget(nil, action: #selector(self.updateBallSize), for: UIControlEvents.valueChanged)
        collisionBehavior.addItem(ballSizeSlider)
        itemBehavior.addItem(ballSizeSlider)
    }
    
    @IBAction func updateBallSize(sender: UISlider) {
        ballSize = CGSize(width: CGFloat(sender.value), height: CGFloat(sender.value))
    }
    
    @IBAction func toggleGravity() {
        gravityOn = !gravityOn
        for (_, ball) in balls.enumerated() {
            if (!gravityOn) {
                gravityBehavior.removeItem(ball)
            }
            if (gravityOn) {
                gravityBehavior.addItem(ball)
            }
        }
    }
    
    deinit {
        for ball in balls {
            ball.removeObserver(self, forKeyPath: "center")
        }
    }
    
    func createPit() {
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
    }
    
    func createBallViews(numBalls: Int) {
        for _ in 0...numBalls {
            let ball = UIView(frame: CGRect.zero)
            ball.backgroundColor = randomColor()
            addSubview(ball)
            balls.append(ball)
        }
        layoutBalls()
    }

    public var ballSize: CGSize = CGSize(width: 50, height: 50) {
        didSet {
            layoutBalls()
        }
    }
    
    public var ballPadding: Double = 0.0 {
        didSet {
            layoutBalls()
        }
    }
    
    private func layoutBalls() {
        let requiredWidth = CGFloat(balls.count) * (ballSize.width + CGFloat(ballPadding))
        for (index, ball) in balls.enumerated() {
            collisionBehavior.removeItem(ball)
            gravityBehavior.removeItem(ball)
            itemBehavior.removeItem(ball)
            let ballXOrigin = ((bounds.width - requiredWidth) / 2.0) + (CGFloat(index) * (ballSize.width + CGFloat(ballPadding)))
            ball.frame = CGRect(x: ballXOrigin, y: bounds.midY, width: ballSize.width, height: ballSize.height)
//            ball.layer.cornerRadius = ball.bounds.width / 2.0
            ball.layer.cornerRadius = 10.0
            collisionBehavior.addItem(ball)
            if (gravityOn) {
                gravityBehavior.addItem(ball)
            }
            itemBehavior.addItem(ball)
        }
    }
    
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: superview)
            for ball in balls {
                if (ball.frame.contains(touchLocation)) {
                    snapBehavior = UISnapBehavior(item: ball, snapTo: touchLocation)
                    animator?.addBehavior(snapBehavior!)
                }
            }
        }
    }

    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: superview)
            if let snapBehavior = snapBehavior {
                snapBehavior.snapPoint = touchLocation
            }
        }
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let snapBehavior = snapBehavior {
            animator?.removeBehavior(snapBehavior)
        }
        snapBehavior = nil
    }
    
}

let ballPit = BallPit(numBalls: 10)

PlaygroundPage.current.liveView = ballPit
