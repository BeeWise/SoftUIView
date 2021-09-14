//
//  SoftUIView.swift
//

import UIKit

@objc
public enum SoftUIViewType: Int {
    case pushButton
    case toggleButton
    case normal
}

@objcMembers
open class SoftUIView: UIControl {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        createSubLayers()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        createSubLayers()
    }

    open func setContentView(_ contentView: UIView?) {
        resetContentView(contentView)
    }

    open func setContentView(_ contentView: UIView?,
                             selectedContentView: UIView?) {
        resetContentView(contentView,
                         selectedContentView: selectedContentView,
                         selectedTransform: nil)
    }

    open func setContentView(_ contentView: UIView?,
                             selectedTransform: CGAffineTransform) {
        resetContentView(contentView,
                         selectedContentView: nil,
                         selectedTransform: selectedTransform)
    }

    open func setContentView(_ contentView: UIView?,
                             selectedContentView: UIView? = nil,
                             selectedTransform: CGAffineTransform? = CGAffineTransform.init(scaleX: 0.95, y: 0.95)) {

        resetContentView(contentView,
                         selectedContentView: selectedContentView,
                         selectedTransform: selectedTransform)
    }

    open var type: SoftUIViewType = .pushButton {
        didSet { updateShadowLayers() }
    }

    open var mainColor: CGColor = SoftUIView.defalutMainColorColor {
        didSet { updateMainColor() }
    }

    open var lightShadow: ShadowModel = SoftUIView.defaultLightShadow {
        didSet { self.updateShadows() }
    }

    open var darkShadow: ShadowModel = SoftUIView.defaultDarkShadow {
        didSet { self.updateShadows() }
    }

    open var cornerRadius: CGFloat = SoftUIView.defalutCornerRadius {
        didSet { updateSublayersShape() }
    }

    open override var bounds: CGRect {
        didSet { updateSublayersShape() }
    }

    open override var isSelected: Bool {
        didSet {
            updateShadowLayers()
            updateContentView()
        }
    }

    open override var backgroundColor: UIColor? {
        get { .clear }
        set { }
    }

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch type {
            case .pushButton:
                isSelected = true
            case .toggleButton:
                isSelected = !isSelected
            case .normal:
                break
        }
        super.touchesBegan(touches, with: event)
    }

    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch type {
            case .pushButton:
                isSelected = isTracking
            case .normal, .toggleButton:
                break
        }
        super.touchesMoved(touches, with: event)
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch type {
            case .pushButton:
                isSelected = false
            case .normal, .toggleButton:
                break
        }
        super.touchesEnded(touches, with: event)
    }

    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch type {
            case .pushButton:
                isSelected = false
            case .normal, .toggleButton:
                break
        }
        super.touchesCancelled(touches, with: event)
    }

    private var backgroundLayer: CALayer!
    private var darkOuterShadowLayer: CAShapeLayer!
    private var lightOuterShadowLayer: CAShapeLayer!
    private var darkInnerShadowLayer: CAShapeLayer!
    private var lightInnerShadowLayer: CAShapeLayer!

    private var contentView: UIView?
    private var selectedContentView: UIView?
    private var selectedTransform: CGAffineTransform?
}

extension SoftUIView {
    public struct ShadowModel {
        public var color: CGColor
        public var offset: CGSize
        public var opacity: Float
        public var radius: CGFloat

        public init(color: CGColor = UIColor.clear.cgColor, offset: CGSize = .zero, opacity: Float = 1, radius: CGFloat = CGFloat.zero) {
            self.color = color
            self.offset = offset
            self.opacity = opacity
            self.radius = radius
        }
    }

    public static let defalutMainColorColor: CGColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
    public static let defalutCornerRadius: CGFloat = 10

    public static let defaultDarkShadow: ShadowModel = ShadowModel(color: #colorLiteral(red: 0.8196078431, green: 0.8039215686, blue: 0.7803921569, alpha: 1), offset: CGSize(width: 6, height: 6), opacity: 1, radius: 5)
    public static let defaultLightShadow: ShadowModel = ShadowModel(color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), offset: CGSize(width: 6, height: 6), opacity: 1, radius: 5)
}

private extension SoftUIView {

    func createSubLayers() {

        lightOuterShadowLayer = {
            let shadowLayer = createOuterShadowLayer(shadowModel: self.lightShadow)
            layer.addSublayer(shadowLayer)
            return shadowLayer
        }()

        darkOuterShadowLayer = {
            let shadowLayer = createOuterShadowLayer(shadowModel: self.darkShadow)
            layer.addSublayer(shadowLayer)
            return shadowLayer
        }()

        backgroundLayer = {
            let backgroundLayer = CALayer()
            layer.addSublayer(backgroundLayer)
            backgroundLayer.frame = bounds
            backgroundLayer.cornerRadius = cornerRadius
            backgroundLayer.backgroundColor = mainColor
            return backgroundLayer
        }()

        darkInnerShadowLayer = {
            let shadowLayer = createInnerShadowLayer(shadowModel: self.darkShadow)
            layer.addSublayer(shadowLayer)
            shadowLayer.isHidden = true
            return shadowLayer
        }()

        lightInnerShadowLayer = {
            let shadowLayer = createInnerShadowLayer(shadowModel: self.lightShadow)
            layer.addSublayer(shadowLayer)
            shadowLayer.isHidden = true
            return shadowLayer
        }()

        updateSublayersShape()
    }

    func createOuterShadowLayer(shadowModel: ShadowModel) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.backgroundColor = UIColor.clear.cgColor
        layer.fillColor = mainColor
        layer.shadowColor = shadowModel.color
        layer.shadowOffset = shadowModel.offset
        layer.shadowOpacity = shadowModel.opacity
        layer.shadowRadius = shadowModel.radius
        return layer
    }

    func createOuterShadowPath() -> CGPath {
        return UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }

    func createInnerShadowLayer(shadowModel: ShadowModel) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.backgroundColor = UIColor.clear.cgColor
        layer.fillColor = mainColor
        layer.shadowColor = shadowModel.color
        layer.shadowOffset = shadowModel.offset
        layer.shadowOpacity = shadowModel.opacity
        layer.shadowRadius = shadowModel.radius
        layer.fillRule = .evenOdd
        return layer
    }

    func createInnerShadowPath() -> CGPath {
        let path = UIBezierPath(roundedRect: bounds.insetBy(dx: -100, dy: -100), cornerRadius: cornerRadius)
        path.append(UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius))
        return path.cgPath
    }

    func createInnerShadowMask() -> CALayer {
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        return layer
    }

    func updateSublayersShape() {
        backgroundLayer.frame = bounds
        backgroundLayer.cornerRadius = cornerRadius

        darkOuterShadowLayer.path = createOuterShadowPath()
        lightOuterShadowLayer.path = createOuterShadowPath()

        darkInnerShadowLayer.path = createInnerShadowPath()
        darkInnerShadowLayer.mask = createInnerShadowMask()

        lightInnerShadowLayer.path = createInnerShadowPath()
        lightInnerShadowLayer.mask = createInnerShadowMask()
    }

    func resetContentView(_ contentView: UIView?,
                          selectedContentView: UIView? = nil,
                          selectedTransform: CGAffineTransform? = CGAffineTransform.init(scaleX: 0.95, y: 0.95)) {

        self.contentView.map {
            $0.transform = .identity
            $0.removeFromSuperview()
        }
        self.selectedContentView.map { $0.removeFromSuperview() }

        contentView.map {
            $0.isUserInteractionEnabled = false
            addSubview($0)
        }
        selectedContentView.map {
            $0.isUserInteractionEnabled = false
            addSubview($0)
        }

        self.contentView = contentView
        self.selectedContentView = selectedContentView
        self.selectedTransform = selectedTransform

        updateContentView()
    }

    func updateContentView() {
        if isSelected, selectedContentView != nil {
            showSelectedContentView()
        } else if isSelected, selectedTransform != nil {
            showSelectedTransform()
        } else {
            showContentView()
        }
    }

    func showContentView() {
        contentView?.isHidden = false
        contentView?.transform = .identity
        selectedContentView?.isHidden = true
    }

    func showSelectedContentView() {
        contentView?.isHidden = true
        contentView?.transform = .identity
        selectedContentView?.isHidden = false
    }

    func showSelectedTransform() {
        contentView?.isHidden = false
        selectedTransform.map { contentView?.transform = $0 }
        selectedContentView?.isHidden = true
    }

    func updateMainColor() {
        backgroundLayer.backgroundColor = mainColor
        darkOuterShadowLayer.fillColor = mainColor
        lightOuterShadowLayer.fillColor = mainColor
        darkInnerShadowLayer.fillColor = mainColor
        lightInnerShadowLayer.fillColor = mainColor
    }

    func updateShadows() {
        self.updateLightShadows()
        self.updateDarkShadows()
    }

    func updateLightShadows() {
        self.lightOuterShadowLayer.shadowColor = self.lightShadow.color
        self.lightOuterShadowLayer.shadowOffset = self.lightShadow.offset
        self.lightOuterShadowLayer.shadowOpacity = self.lightShadow.opacity
        self.lightOuterShadowLayer.shadowRadius = self.lightShadow.radius

        self.lightInnerShadowLayer.shadowColor = self.lightShadow.color
        self.lightInnerShadowLayer.shadowOffset = self.lightShadow.offset
        self.lightInnerShadowLayer.shadowOpacity = self.lightShadow.opacity
        self.lightInnerShadowLayer.shadowRadius = self.lightShadow.radius
    }

    func updateDarkShadows() {
        self.darkOuterShadowLayer.shadowColor = self.darkShadow.color
        self.darkOuterShadowLayer.shadowOffset = self.darkShadow.offset
        self.darkOuterShadowLayer.shadowOpacity = self.darkShadow.opacity
        self.darkOuterShadowLayer.shadowRadius = self.darkShadow.radius

        self.darkInnerShadowLayer.shadowColor = self.darkShadow.color
        self.darkInnerShadowLayer.shadowOffset = self.darkShadow.offset
        self.darkInnerShadowLayer.shadowOpacity = self.darkShadow.opacity
        self.darkInnerShadowLayer.shadowRadius = self.darkShadow.radius
    }

    func updateShadowLayers() {
        darkOuterShadowLayer.isHidden = isSelected
        lightOuterShadowLayer.isHidden = isSelected
        darkInnerShadowLayer.isHidden = !isSelected
        lightInnerShadowLayer.isHidden = !isSelected
    }
}

extension CGSize {

    var inverse: CGSize {
        .init(width: -1 * width, height: -1 * height)
    }

}
