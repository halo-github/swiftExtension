//
//  UIView-Extensive.swift

//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit
let SYSVERSION = Double(UIDevice.current.systemVersion)!   //系统版本

let MAINWIDTH:CGFloat = UIScreen.main.bounds.width
var MAINHEIGHT:CGFloat = UIScreen.main.bounds.height

//以6的尺寸为标准
let scale6 = MAINWIDTH/375
let XHspace: CGFloat = 16
let XHshortSpace: CGFloat = 10


func W6(w:CGFloat) -> CGFloat {
    return scale6*w
}
func H6(h:CGFloat) -> CGFloat {
    return scale6*h
}

enum Device:CGFloat {      //机型
    case type4 = 480
    case type5 = 568
    case type6 = 667
    case type6P = 736
    case typeX = 812
}

var XStatubarExtraHeight:CGFloat {
    return  MAINHEIGHT == 812  ? 24 : 0
}

var NAVIBARHEIGHT:CGFloat  {        //导航栏
    if MAINHEIGHT == 812 {
        return 88
    }
    return 64
//     if MAINHEIGHT == Device.typeX.rawValue {
//        if UIViewController.currentViewController().hideNaviBar == true {
//            return 44
//        }
//        return 88
//    }
//    else {
//        return 64
//    }
}
var STATUSBARHEIGHT:CGFloat {                  //状态栏
     if MAINHEIGHT == 812 {
        return 44
    } else {
        return 20
    }
}

var TABBARHEIGHT:CGFloat {  
    //tabbar
    if MAINHEIGHT == 812 {
        return 83
    }
    return 49
}
var tabBarExtraHeght: CGFloat {
    if MAINHEIGHT == 812 {
        return 34
    }
    return 0
}
//安全高度
let SAFESCREENHEIGHT = MAINHEIGHT - NAVIBARHEIGHT - TABBARHEIGHT
let SAFEHEIGHTONLYNAVI = MAINHEIGHT - NAVIBARHEIGHT
let SAFEHEIGHTONLYTAB =  MAINHEIGHT - TABBARHEIGHT



extension CGRect {
    static func Xinit(x:CGFloat, y:CGFloat, width:CGFloat, height:CGFloat,isTop:Bool = false) -> CGRect {
//        let newY = isTop ?  y : XStatubarExtraHeight + y
        let newHeight = isTop ? height + XStatubarExtraHeight : height
        return self.init(x: x * scale6, y: y * scale6, width: width * scale6, height: newHeight * scale6)
    }
}

//MARK:-为view提供内存管理
extension UIView:LFassociateObject {
    static var bagKey = UnsafeRawPointer("bag")
    var bag:DisposeBag {
        guard let bag = objc_getAssociatedObject(newInstance, UIView.bagKey) else {
            let bag = DisposeBag()
            objc_setAssociatedObject(newInstance, UIView.bagKey, bag, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return bag
        }
        return bag as! DisposeBag
    }
}
//MARK:- UIView frame属性
extension UIView {
    var maxHeight: CGFloat {
        var maxHeight: CGFloat = 0
        maxHeight = self.subviews.reduce(maxHeight) { (new, view) -> CGFloat in
            max(view.y() + view.height(), new)
        }
        return maxHeight + XHspace
    }
    var maxWidth: CGFloat {
        var maxWidth: CGFloat = 0
        maxWidth = self.subviews.reduce(maxWidth) { (new, view) -> CGFloat in
            max(view.x() + view.width(), new)
        }
        return maxHeight + XHspace
    }
    func resize<T:UIView>(newSize: CGSize,type:T.Type   ) -> T {
        self.frame.size = newSize
        return self as! T
    }
    
   
    
    func xh_addTo(sup:UIView, x: CGFloat, y:CGFloat, width:CGFloat, height:CGFloat) {
        self.frame = CGRect.Xinit(x: x, y: y, width: width, height: height)
        sup.addSubview(self)
    }
    
   class func W6(w:CGFloat) -> CGFloat {
        return MAINWIDTH/375*w
    }
    
    class func Y6(y:CGFloat) -> CGFloat {
        if MAINHEIGHT == Device.typeX.rawValue {
            return y+24
        } else {
            return y
        }
    }
   
    
    
   
    
    func set(x:CGFloat) -> Void {
        self.frame = CGRect.Xinit(x: x, y: self.y(), width: self.width(), height: self.height())
    }
    func set(y:CGFloat) -> Void {
        self.frame = CGRect.Xinit(x: self.x(), y: y, width: self.width(), height: self.height())
    }
    func set(width:CGFloat) -> Void {
        self.frame = CGRect.Xinit(x: self.x(), y: self.y(), width: width, height: self.height())
    }
    func set(height:CGFloat) -> Void {
        self.frame = CGRect.Xinit(x: self.x(), y: self.y(), width: self.width(), height: height)
    }
    func set(size:CGSize) -> Void {
        self.frame = CGRect.Xinit(x: self.x(), y: self.y(), width: size.width, height: size.height)
    }
    func x() -> CGFloat {
        return self.frame.origin.x
    }
    
    func y() -> CGFloat {
        return self.frame.origin.y
    }
    func size() -> CGSize {
        return self.frame.size
    }
    func width() -> CGFloat {
        return self.size().width
    }
    func height() -> CGFloat {
        return self.size().height
    }
    
    
    enum ViewLayoutDirection {    //排列方向
        case horizon
        case vertical
    }
//    水平等比排列
    func layoutHorinzon(views:[UIView],margin:CGFloat,size:CGSize) {
        let count = views.count
        let totalSpace = self.width() - CGFloat(count) * size.width - 2 * margin
        let space = totalSpace/CGFloat(count - 1)
        for (idx,view) in views.enumerated() {
            self.addSubview(view)
            let centerX = margin + size.width/2 + CGFloat(idx) * (space + size.width)
            view.snp.makeConstraints({ (make) in
                make.size.equalTo(size).multipliedBy(scale6)
                make.centerY.equalToSuperview()
                make.centerX.equalTo(centerX)
            })
        }
    }
    //垂直等比排列
    func layoutVertical(views:[UIView],margin:CGFloat,size:CGSize) {
        let count = views.count
        let totalSpace = self.height() - CGFloat(count) * size.height - 2 * margin
        let space = totalSpace/CGFloat(count - 1)
        for (idx,view) in views.enumerated() {
            self.addSubview(view)
            let centerY = margin + size.height/2 + CGFloat(idx) * (space + size.height)
            view.snp.makeConstraints({ (make) in
                make.size.equalTo(size).multipliedBy(scale6)
                make.centerX.equalToSuperview()
                make.centerY.equalTo(centerY)
            })
        }
    }
    
//    底部线条
    func addBottomLine() -> Void {
        let line = UIView()
        self.addSubview(line)
        line.backgroundColor = UIColor.hex("#F2F2F2")
        line.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.left.equalTo(16).multipliedBy(scale6)
            make.right.equalTo(-16).multipliedBy(scale6)
            make.bottom.equalToSuperview()
        }
    }
}

struct LayoutStruct {
    var target:targetConstrainType
    var vertical:CGFloat
    var horizon:CGFloat
    var width:CGFloat
    var height:CGFloat

}
enum targetConstrainType {
    case horizon(to:UIView)
    case vertical(to:UIView)
    case superview(view:UIView)
}
//enum ConstraintDiretion {
//    case horizon(_d:HorizonDirection)
//    case vertical(_d:VerticalDrection)
//}










private func scale6(_ f:CGFloat) -> CGFloat {
        return f * scale6
}
enum TargetViewType {
    enum HorizonAlign {
        case left,right,center
    }
    enum VerticalAlign {
        case top,bottom,center
    }
    enum HorizonDirection {
        case left(ConstraintRelatableTarget)
        case right(ConstraintRelatableTarget)
        case center(multipliedBy:CGFloat)
        case divide(divided: CGFloat, index: CGFloat)
        case align(HorizonAlign)
    }
    enum VerticalDrection {
        case top(ConstraintRelatableTarget)
        case bottom(ConstraintRelatableTarget)
        case center(multipliedBy:CGFloat)
        case divide(divided: CGFloat, index: CGFloat)
        case align(VerticalAlign)
    }
    case sup_vertical(v:VerticalDrection)
    case sup_horizon(h:HorizonDirection)
    case sub_vertical(v:VerticalDrection)
    case sub_horizon(h:HorizonDirection)
}


//MARK:- snp 的封装
extension UIView{

//约束的时候统一使用left,top,width,height，以根据屏幕宽度适配机型
//iPhone X 额外判断
    
    //二等分父视图，子视图中心点分别在父视图的 1/4，3/4
    //三等分父视图，子视图中心点分别在父视图的 1/6，1/2，5/6
    
//    func xh_divide(views:[UIView]){
//        let count = views.count
//        for (i,view) in views.enumerated() {
//            view.xh_sup_centerY(view: self, multX: CGFloat(i/count + 1/(count * 2)), width: -1, height: -1)
//        }
//    }
    
    
    func convert(_ contraintTarget:ConstraintRelatableTarget) -> ConstraintRelatableTarget {
        //有瑕疵   swift 的类型判断会自动判断整数为 Int， 从而不能转换成CGFloat
        if contraintTarget is CGFloat {
            let  tg  = contraintTarget as! CGFloat
            return tg * scale6
        }
        if  let tg = contraintTarget as? Int {
            return CGFloat(tg) * scale6
        }
        return contraintTarget
    }
    // 父视图左上约束
    func xh_super_left(_ sup:UIView, top:ConstraintRelatableTarget, left:ConstraintRelatableTarget, width:ConstraintRelatableTarget, height:ConstraintRelatableTarget ) {
        self.xh_layout(view: sup,
                       vertical: .sup_vertical(v: .top(top)),
                       horizon: .sup_horizon(h: .left(left)),
                       width: width,
                       height: height)
    }
    //父视图右上约束
    func xh_super_right(_ sup:UIView, top:ConstraintRelatableTarget, right:ConstraintRelatableTarget, width:ConstraintRelatableTarget, height:ConstraintRelatableTarget ) {
        self.xh_layout(view: sup,
                            vertical: .sup_vertical(v: .top(top)),
                            horizon: .sup_horizon(h: .right(right)),
                            width: width,
                            height: height)
    }
    //父视图水平居中，顶约束
    func xh_super_centerX(_ sup:UIView, top:ConstraintRelatableTarget, width:ConstraintRelatableTarget, height:ConstraintRelatableTarget ) {
        self.xh_layout(view: sup,
                       vertical: .sup_vertical(v: .top(top)),
                       horizon: .sup_horizon(h: .align(.center)),
                       width: width,
                       height: height)
    }
    //父视图居中对齐，左约束
    func xh_sup_centerY(_ sup:UIView, left:ConstraintRelatableTarget, width:ConstraintRelatableTarget, height:ConstraintRelatableTarget)  {
        self.xh_layout(view: sup, vertical: .sup_vertical(v: .align(.center)), horizon: .sup_horizon(h: .left(left)), width: width, height: height)
    }
    //父视图居中对齐，右约束
    func xh_sup_centerY(_ sup:UIView, right:ConstraintRelatableTarget, width:ConstraintRelatableTarget, height:ConstraintRelatableTarget)  {
        self.xh_layout(view: sup, vertical: .sup_vertical(v: .align(.center)), horizon: .sup_horizon(h: .right(right)), width: width, height: height)
    }
    //子视图居中对齐，左约束
    func xh_sub_centerY(_ sub:UIView, left:ConstraintRelatableTarget, width:ConstraintRelatableTarget, height:ConstraintRelatableTarget ) {
        self.xh_layout(view: sub,
                       vertical: .sub_vertical(v: .align(.center)),
                       horizon: .sub_horizon(h: .left(left)),
                       width: width,
                       height: height)
    }
    //子视图中心水平对齐
    func xh_sub_centerY(_ sub:UIView, right:ConstraintRelatableTarget, width:ConstraintRelatableTarget, height:ConstraintRelatableTarget ) {
        self.xh_layout(view: sub,
                       vertical: .sub_vertical(v: .align(.center)),
                       horizon: .sub_horizon(h: .right(right)),
                       width: width,
                       height: height)
    }
    //子视图中心水平对齐
    func xh_sub_centerY(_ sub:UIView, sup_right:ConstraintRelatableTarget, width:ConstraintRelatableTarget, height:ConstraintRelatableTarget ) {
        self.xh_layout(view: sub,
                       vertical: .sub_vertical(v: .align(.center)),
                       horizon: .sup_horizon(h: .right(sup_right)),
                       width: width,
                       height: height)
    }
    //子视图垂直对齐
    func xh_sub_left(_ sub:UIView, top:ConstraintRelatableTarget, width:ConstraintRelatableTarget, height:ConstraintRelatableTarget ) {
        self.xh_layout(view: sub,
                       vertical: .sub_vertical(v: .top(top)),
                       horizon: .sub_horizon(h: .align(.left)),
                       width: width,
                       height: height)
    }
    // 子视图底部对父视图，左约束
    func xh_sup_bottom(_ sup:UIView, bottom:ConstraintRelatableTarget, left:ConstraintRelatableTarget, width:ConstraintRelatableTarget, height:ConstraintRelatableTarget) {
        self.xh_layout(view: sup,
                       vertical: .sup_vertical(v: .bottom(bottom)),
                       horizon: .sup_horizon(h: .left(left)),
                       width: width, height: height)
    }
    
    // 子视图底部对父视图,右约束
    func xh_sup_bottom(_ sup:UIView, bottom:ConstraintRelatableTarget, right:ConstraintRelatableTarget, width:ConstraintRelatableTarget, height:ConstraintRelatableTarget) {
        self.xh_layout(view: sup,
                       vertical: .sup_vertical(v: .bottom(bottom)),
                       horizon: .sup_horizon(h: .right(right)),
                       width: width, height: height)
    }
    //子视图居中，底部约束
    func xh_sup_bottom_centerX(_ sup:UIView, bottom:ConstraintRelatableTarget,  width:ConstraintRelatableTarget, height:ConstraintRelatableTarget) {
        self.xh_layout(view: sup, vertical: .sup_vertical(v: .bottom(bottom)), horizon: .sup_horizon(h: .align(.center)), width: width, height: height)
    }
    
    //子视图中心垂直对齐
    func xh_sub_centerX(_ sub:UIView, top:ConstraintRelatableTarget, width:ConstraintRelatableTarget, height:ConstraintRelatableTarget ) {
        self.xh_layout(view: sub,
                       vertical: .sub_vertical(v: .top(top)),     //垂直间隔
                       horizon: .sub_horizon(h: .align(.center)),
                       width: width,
                       height: height)
    }
    //子视图顶对齐
    func xh_sub_equal_top(_ sub:UIView, left:ConstraintRelatableTarget, width:ConstraintRelatableTarget, height:ConstraintRelatableTarget) {
        self.xh_layout(view: sub,
                       vertical: .sub_vertical(v: .align(.top)),
                       horizon: .sub_horizon(h: .left(left)),
                       width: width, height: height)
    }
    //父视图左约束，子视图顶约束
    func xh_sub_top_sup_left(_ sub:UIView, top:ConstraintRelatableTarget, left:ConstraintRelatableTarget, width:ConstraintRelatableTarget, height:ConstraintRelatableTarget) {
        self.xh_layout(view: sub, vertical: .sub_vertical(v: .top(top)), horizon: .sup_horizon(h: .left(left)), width: width, height: height)
    }
    //父视图右约束，子视图左约束
    func xh_sub_top_sup_right(_ sub:UIView, top:ConstraintRelatableTarget, right:ConstraintRelatableTarget, width:ConstraintRelatableTarget, height:ConstraintRelatableTarget) {
        self.xh_layout(view: sub, vertical: .sub_vertical(v: .top(top)), horizon: .sup_horizon(h: .right(right)), width: width, height: height)
    }
    
    //子视图垂直中心对齐，父视图右约束
    func xh_sub_centerY_super_right(_ sub:UIView, right:ConstraintRelatableTarget,width:ConstraintRelatableTarget, height:ConstraintRelatableTarget) {
        self.xh_layout(view: sub, vertical: .sub_vertical(v: .align(.center)), horizon: .sup_horizon(h: .right(right)), width: width, height: height)
    }
    //父视图水平等分
    func xh_sup_multCenterX(_ sup: UIView, top:ConstraintRelatableTarget, multX: CGFloat, width:ConstraintRelatableTarget, height:ConstraintRelatableTarget) {
        xh_layout(view: sup,
                  vertical: .sup_vertical(v: .top(top)),
                  horizon: .sup_horizon(h: .center(multipliedBy: multX)),
                  width: width, height: height)
    }
    //父视图垂直等分
    func xh_sup_multCenterY(_ sup: UIView, left:ConstraintRelatableTarget, multipliedBy: CGFloat, width:ConstraintRelatableTarget, height:ConstraintRelatableTarget) {
        xh_layout(view: sup,
                  vertical: .sup_vertical(v: .center(multipliedBy: multipliedBy)),
                  horizon: .sup_horizon(h: .left(left)),
                  width: width, height: height)
    }
    
    //Y轴居中，X轴等分
    func xh_sup_centerY(view:UIView, multX: CGFloat, width:ConstraintRelatableTarget, height:ConstraintRelatableTarget) {
        self.xh_layout(view: view, vertical: .sup_vertical(v: .align(.center)), horizon: .sup_horizon(h: .center(multipliedBy: multX)), width: width, height: height)
    }
    
    //X轴居中，Y轴等分
    func xh_sup_centerX(view:UIView, multY: CGFloat, width:ConstraintRelatableTarget, height:ConstraintRelatableTarget) {
        self.xh_layout(view: view, vertical: .sup_vertical(v: .center(multipliedBy: multY)), horizon: .sub_horizon(h: .align(.center)), width: width, height: height)
    }
    
    // x,y按比例排列
    func xh_sup_multXY(view:UIView,multY:CGFloat, multX:CGFloat,  width:ConstraintRelatableTarget, height:ConstraintRelatableTarget) {
        self.xh_layout(view: view, vertical: .sup_vertical(v: .center(multipliedBy: multY)),
                       horizon: .sup_horizon(h: .center(multipliedBy: multX)), width: width, height: height)
    }
    
    func xh_sup_divideXY(view:UIView,YdividedBy:CGFloat, Yindex:CGFloat, XdividedBy:CGFloat, Xindex: CGFloat, width:ConstraintRelatableTarget, height:ConstraintRelatableTarget) {
    self.xh_layout(view: view, vertical: .sup_vertical(v: .divide(divided: YdividedBy, index: Yindex)), horizon: .sup_horizon(h: .divide(divided: XdividedBy, index: Xindex)), width: width, height: height)
    }
    
    //x,y居中
    func xh_sup_centerXY(view:UIView, width:ConstraintRelatableTarget, height:ConstraintRelatableTarget) {
        self.xh_layout(view: view,
                       vertical: .sup_vertical(v: .align(.center)), horizon: .sup_horizon(h: .align(.center)),
                       width: width, height: height)
    }
    

    
    //根视图底部，tabbar约束
    func xh_sub_top_bottom_to_tabBar(view:UIView, hideTabBar:Bool, top: ConstraintOffsetTarget,left: ConstraintOffsetTarget,width:ConstraintRelatableTarget) {
        let sup  = view.superview
        sup?.addSubview(self)
        self.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.bottom).offset(top)
            make.left.equalTo((sup?.snp.left)!).offset(left)
            let offSet = hideTabBar == true ? -tabBarExtraHeght : -TABBARHEIGHT
            make.bottom.equalToSuperview().offset(offSet)
            make.width.equalTo(width)
        }
    }
    

    // 100行的函数我也很无语，switch帮了大忙
//    主要是提供一个水平约束和一个垂直约束，并区别对待父视图和子视图，各种对齐方式
    func xh_layout(view:UIView, vertical:TargetViewType, horizon:TargetViewType, width:ConstraintRelatableTarget, height:ConstraintRelatableTarget) {
        if case TargetViewType.sub_horizon(_) = horizon {               //模式匹配 if case let
            guard let sup = view.superview else {return}
            sup.addSubview(self)
        }
        else if case TargetViewType.sub_vertical(_) = vertical {
            guard let sup = view.superview else {return}
            sup.addSubview(self)
        }
        else {
            view.addSubview(self)
        }
        
        
        
        
        self.snp.makeConstraints { (make) in
            self.widthConstraint(make: make, width: width)
            self.heightConstraint(make: make, height: height)
            self.verticalConstraint(view: view, make: make, vertical: vertical)
            self.horizonConstraint(view: view, make: make, horizon: horizon)
        }

    }
    
    
    
    
    func  widthConstraint(make:ConstraintMaker, width:ConstraintRelatableTarget) {
        if let wid = convert(width) as? CGFloat {
            if wid > -0.5 {                      //测送中5s，wid为-0.83
                make.width.equalTo(wid)
            }
        } else {
            make.width.equalTo(width)
        }
}
    func  heightConstraint(make:ConstraintMaker, height:ConstraintRelatableTarget) {
        if let ht = convert(height) as? CGFloat {
            if ht > -0.5 {
                make.height.equalTo(ht)
            }
        } else {
            make.height.equalTo(height)
        }
    }
    //垂直方向
    func  verticalConstraint(view:UIView, make:ConstraintMaker, vertical:TargetViewType){
        switch vertical{
        case .sup_vertical(let v):
            switch v {
            case .center(multipliedBy: let mult) :
                make.centerY.equalToSuperview().multipliedBy(mult * 2)
            case .top(let equal):
                make.top.equalTo(equal)
            case .bottom(let equal): do {
                var newBottom: CGFloat = 0
                if self.superview?.next is UIViewController {
                    if let eq = convert(equal) as? CGFloat {
                        newBottom = eq - tabBarExtraHeght
                        make.bottom.equalTo(newBottom)
                    }
                } else {
                make.bottom.equalTo(convert(equal))
                    }
                }
            case .divide(let divided, let idx):
                make.centerY.equalToSuperview().multipliedBy((1/CGFloat(divided) * CGFloat(idx) + 1/CGFloat(divided * 2)) * 2)
                
                
            case .align(let v): do {
                switch v {
                case .top:
                    make.top.equalToSuperview()
                case .bottom:
                    make.bottom.equalToSuperview()
                case .center:
                    make.centerY.equalToSuperview()

                }
                
                }
            }
        case .sub_vertical(let v):
            switch v {
            case .top(let equal):
                make.top.equalTo(view.snp.bottom).offset(convert(equal) as! ConstraintOffsetTarget)
            case .bottom(let equal):
                make.bottom.equalTo(view.snp.top).offset(convert(equal)  as! ConstraintOffsetTarget)
            case .divide(let divided, let idx):
                make.centerY.equalToSuperview().multipliedBy((1/CGFloat(divided) * CGFloat(idx) + 1/CGFloat(divided * 2)) * 2)
            case .align(let type):
                switch type {case .top:
                    make.top.equalTo(view)
                case .bottom:
                    make.bottom.equalTo(view)
                case .center:
                    make.centerY.equalTo(view)
                }
            case .center(let multipliedBy):
                make.centerY.equalToSuperview().multipliedBy(multipliedBy * 2)
            }
        default : break
            }
        }
    
    //水平方向
    func  horizonConstraint(view:UIView, make:ConstraintMaker, horizon:TargetViewType){
        switch horizon {
            case .sup_horizon(let h):
                switch h {
                    case .left(let equal):
                        make.left.equalTo(convert(equal))
                    case .right(let equal):
                        make.right.equalTo(convert(equal))
                case .divide(let divided, let idx):
                    make.centerX.equalToSuperview().multipliedBy((1/CGFloat(divided) * CGFloat(idx) + 1/CGFloat(divided * 2)) * 2)
                case .align(let type):
                    switch type {case .left:
                        make.left.equalTo(view)
                    case .right:
                        make.right.equalTo(view)
                    case .center:
                        make.centerX.equalTo(view)
                    }
                case .center(let multipliedBy):
                    make.centerX.equalToSuperview().multipliedBy(multipliedBy * 2)
            }
            case .sub_horizon(let h):
                switch h {
                    case .left(let equal):
                        make.left.equalTo(view.snp.right).offset(convert(equal) as! ConstraintOffsetTarget)
                    case .right(let equal):
                        make.right.equalTo(view.snp.left).offset(convert(equal) as! ConstraintOffsetTarget)
                case .divide(let divided, let idx):
                    make.centerX.equalToSuperview().multipliedBy((1/CGFloat(divided) * CGFloat(idx) + 1/CGFloat(divided * 2)) * 2)
                    case .align(let type):
                    switch type {case .left:
                        make.left.equalTo(view)
                    case .right:
                        make.right.equalTo(view)
                    case .center:
                        make.centerX.equalTo(view)
                    }
                case .center(let multipliedBy):
                    make.centerX.equalTo(view).multipliedBy(multipliedBy * 2)
            }
                    default : break
        }
    }
}




