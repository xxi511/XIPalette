# XIPalette
A swift implement Color picker
![](https://github.com/xxi511/XIPalette/blob/master/demo.png)
## Requirements
* iOS 10.0 +
* swift 4.2

## install
### Manual
copy everything in color/Source
### Carthage
`github "xxi511/XIPalette"`

## How to use
```
import XIPalette
class ViewController: UIViewController {
    @IBAction func clickBtn(_ sender: Any) {
        let vc = XIPalettePopVC.instance()
        vc.delegate = self
        vc.present(at: self)
    }
}

extension ViewController: XIPaletteDelegate {
    func select(color: UIColor) {
        self.view.backgroundColor = color
    }
}
```

or you can use `ColorWheelView` and `ColorSlider` to build your color picker, detail can see in `XIPalettePopVC`
