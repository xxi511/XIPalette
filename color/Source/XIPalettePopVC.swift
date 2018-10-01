//
//  PalettePopVC.swift
//  color
//
//  Created by 陳建佑 on 12/04/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import UIKit

public protocol XIPaletteDelegate {
    func select(color: UIColor)
}

public class XIPalettePopVC: UIViewController {
    @IBOutlet private  var colorWheel: ColorWheelView!
    @IBOutlet private var colorSlider: ColorSlider!
    @IBOutlet private var checkBtn: UIButton!
    @IBOutlet private var closeBtn: UIButton!
    @IBOutlet private var background: UIView!
    public var delegate: XIPaletteDelegate?

    public class func instance() -> XIPalettePopVC {
        let vc = XIPalettePopVC(nibName: "XIPalettePopVC", bundle: Bundle(for: XIPalettePopVC.self))
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .flipHorizontal
        return vc
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.addGesture()
        self.colorWheel.delegate = self
        self.colorSlider.delegate = self
        self.setCloseBtn()
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction private func clickClose(_ sender: Any) {
        self.removeAnimate()
    }

    @IBAction private func clickSelectBtn(_ sender: Any) {
        self.delegate?.select(color: self.checkBtn.backgroundColor!)
        self.removeAnimate()
    }

    public func present(at parent: UIViewController) {
        parent.addChildViewController(self)
        self.didMove(toParentViewController: parent)
        parent.view.addSubview(self.view)
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.topAnchor.constraint(equalTo: parent.view.topAnchor).isActive = true
        self.view.bottomAnchor.constraint(equalTo: parent.view.bottomAnchor).isActive = true
        self.view.leftAnchor.constraint(equalTo: parent.view.leftAnchor).isActive = true
        self.view.rightAnchor.constraint(equalTo: parent.view.rightAnchor).isActive = true
        self.showAnimate()
    }
}

extension XIPalettePopVC: ColorWheelProtocol {
    public func colorPick(color: UIColor) {
        self.colorSlider.selectedColor = color
        self.checkBtn.backgroundColor = color
    }
}

extension XIPalettePopVC: ColorSliderProtocol {
    public func colorSlider(bright: CGFloat) {
        self.colorWheel.brightness = bright
    }
}

// MARK: Funcs
extension XIPalettePopVC {
    private func showAnimate() {
        
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }

    @objc private func removeAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }, completion: {(finished : Bool) in
            if(finished)
            {
                self.willMove(toParentViewController: nil)
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
            }
        })
    }

    private func addGesture() {
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(self.removeAnimate))
        self.background.addGestureRecognizer(tapGes)
    }

    private func computeColor(color: UIColor) {
        var hue: CGFloat = 0
        var sat: CGFloat = 0
        var bright: CGFloat = 0

        color.getHue(&hue, saturation: &sat, brightness: &bright, alpha: nil)
        hue = (hue > 0.5) ? hue + 0.5: hue - 0.5
        let result = UIColor(hue: hue, saturation: sat, brightness: 1-bright, alpha: 1)
        self.checkBtn.titleLabel?.textColor = result
    }

    private func setCloseBtn() {
        self.closeBtn.layer.cornerRadius = 15

        let aLayer = self.drawLine(p1: CGPoint(x: 8, y: 8), to: CGPoint(x: 22, y: 22))
        let bLayer = self.drawLine(p1: CGPoint(x: 8, y: 22), to: CGPoint(x: 22, y: 8))
        self.closeBtn.layer.addSublayer(aLayer)
        self.closeBtn.layer.addSublayer(bLayer)
    }

    private func drawLine(p1: CGPoint, to p2: CGPoint) -> CAShapeLayer {
        let aPath = UIBezierPath()
        aPath.move(to: p1)
        aPath.addLine(to: p2)
        aPath.lineWidth = 2
        aPath.close()
        let aLayer = CAShapeLayer()
        aLayer.path = aPath.cgPath
        aLayer.fillColor = UIColor.clear.cgColor
        aLayer.strokeColor = UIColor.white.cgColor
        return aLayer
    }

}
