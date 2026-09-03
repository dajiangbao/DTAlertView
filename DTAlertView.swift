//
//  DTAlertView.swift
//  MCO3
//
//  Created by rey on 2026/9/1.
//  AlertView

import UIKit
import SnapKit

// MARK: - 主窗口获取（兼容iOS15+废弃警告）
extension UIApplication {
    var dt_mainWindow: UIWindow? {
        if #available(iOS 15.0, *) {
            return connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .compactMap { $0 as? UIWindowScene }
                .first?.windows
                .first(where: \.isKeyWindow)
        } else {
            return windows.first(where: \.isKeyWindow)
        }
    }
}

// MARK: - 十六进制颜色扩展
extension UIColor {
    convenience init(hex: String) {
        let hexStr = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var hexValue: UInt64 = 0
        Scanner(string: hexStr).scanHexInt64(&hexValue)
        let r = CGFloat((hexValue >> 16) & 0xFF) / 255.0
        let g = CGFloat((hexValue >> 8) & 0xFF) / 255.0
        let b = CGFloat(hexValue & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}

// MARK: - 弹窗核心视图
class DTAlertView: UIView {
    // 按钮点击回调
    var leftAction: (() -> Void)?
    var rightAction: (() -> Void)?
    
    // MARK: - UI 组件
    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 8
        v.clipsToBounds = true
        return v
    }()
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .boldSystemFont(ofSize: 18)
        l.textColor = UIColor(hex: "#333333")
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()
    
    private let scrollView: UIScrollView = {
        let s = UIScrollView()
        s.showsVerticalScrollIndicator = true
        s.showsHorizontalScrollIndicator = false
        s.bounces = false
        s.contentInsetAdjustmentBehavior = .never
        return s
    }()
    
    private let contentLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16)
        l.textColor = UIColor(hex: "#666666")
        l.textAlignment = .center
        l.numberOfLines = 0
        l.setContentCompressionResistancePriority(.required, for: .vertical)
        return l
    }()
    
    private let leftBtn: UIButton = {
        let b = UIButton(type: .custom)
        b.titleLabel?.font = .systemFont(ofSize: 16)
        b.setTitleColor(UIColor(hex: "#005BE6"), for: .normal)
        b.backgroundColor = UIColor(hex: "#F2F3FF")
        b.layer.cornerRadius = 4
        return b
    }()
    
    private let rightBtn: UIButton = {
        let b = UIButton(type: .custom)
        b.titleLabel?.font = .systemFont(ofSize: 16)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = UIColor(hex: "#005BE6")
        b.layer.cornerRadius = 4
        return b
    }()
    
    // MARK: - 布局常量
    private let kHMargin: CGFloat = 20    // 左右统一边距
    private let kBtnHeight: CGFloat = 44  // 按钮固定高度
    private let kBottom: CGFloat = 16     // 按钮底部边距
    private let kTop: CGFloat = 20        // 标题顶部边距
    private let kGap: CGFloat = 12        // 元素间距
    
    // MARK: - 初始化
    init(title: String?, content: String?, leftTitle: String?, rightTitle: String) {
        super.init(frame: .zero)
        setupUI()
        setupData(title: title, content: content, leftTitle: leftTitle, rightTitle: rightTitle)
        setupConstraints(isSingle: leftTitle == nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // 半透明蒙层
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(scrollView)
        scrollView.addSubview(contentLabel)
        containerView.addSubview(leftBtn)
        containerView.addSubview(rightBtn)
        
        leftBtn.addTarget(self, action: #selector(leftBtnClick), for: .touchUpInside)
        rightBtn.addTarget(self, action: #selector(rightBtnClick), for: .touchUpInside)
    }
    
    private func setupData(title: String?, content: String?, leftTitle: String?, rightTitle: String) {
        titleLabel.text = title
        titleLabel.isHidden = title == nil
        
        contentLabel.text = content
        scrollView.isHidden = content == nil
        
        leftBtn.setTitle(leftTitle, for: .normal)
        leftBtn.isHidden = leftTitle == nil
        
        rightBtn.setTitle(rightTitle, for: .normal)
    }
    
    private func setupConstraints(isSingle: Bool) {
        let containerWidth = UIScreen.main.bounds.width - 60 // 左右各距屏幕30
        
        // 容器：垂直居中、宽度固定、高度由内容撑开、最大不超屏幕
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(containerWidth)
            make.height.lessThanOrEqualToSuperview().offset(-40).priority(.required)
        }
        
        // 1. 标题约束
        if !titleLabel.isHidden {
            titleLabel.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(kTop)
                make.left.equalToSuperview().offset(kHMargin)
                make.right.equalToSuperview().offset(-kHMargin)
            }
        }
        
        // 2. 滚动视图 + 内容约束
        if !scrollView.isHidden {
            // 滚动视图：顶部接标题，左右贴边
            scrollView.snp.makeConstraints { make in
                if !titleLabel.isHidden {
                    make.top.equalTo(titleLabel.snp.bottom).offset(kGap)
                } else {
                    make.top.equalToSuperview().offset(kTop)
                }
                make.left.equalToSuperview().offset(kHMargin)
                make.right.equalToSuperview().offset(-kHMargin)
                // ✅ 核心修复：滚动高度优先跟随内容高度，超过最大高度后自动变成滚动
                make.height.equalTo(contentLabel.snp.height).priority(UILayoutPriority.defaultHigh.rawValue)
            }
            
            // 内容label：四边贴紧滚动视图，宽度和滚动视图一致
            contentLabel.snp.makeConstraints { make in
                make.edges.equalToSuperview()
                make.width.equalTo(scrollView.snp.width)
            }
        }
        
        // 3. 按钮约束（底部固定高度区域）
        if isSingle {
            // 单按钮：宽度撑满内容区
            rightBtn.snp.makeConstraints { make in
                // 顶部接内容/标题
                if !scrollView.isHidden {
                    make.top.equalTo(scrollView.snp.bottom).offset(kGap)
                } else {
                    make.top.equalTo(titleLabel.isHidden ? kTop : titleLabel.snp.bottom).offset(kGap)
                }
                make.left.equalToSuperview().offset(kHMargin)
                make.right.equalToSuperview().offset(-kHMargin)
                make.bottom.equalToSuperview().offset(-kBottom)
                make.height.equalTo(kBtnHeight)
            }
        } else {
            // 双按钮：左右等分
            leftBtn.snp.makeConstraints { make in
                if !scrollView.isHidden {
                    make.top.equalTo(scrollView.snp.bottom).offset(kGap)
                } else {
                    make.top.equalTo(titleLabel.isHidden ? kTop : titleLabel.snp.bottom).offset(kGap)
                }
                make.left.equalToSuperview().offset(kHMargin)
                make.bottom.equalToSuperview().offset(-kBottom)
                make.height.equalTo(kBtnHeight)
                make.width.equalTo(rightBtn.snp.width)
            }
            
            rightBtn.snp.makeConstraints { make in
                if !scrollView.isHidden {
                    make.top.equalTo(scrollView.snp.bottom).offset(kGap)
                } else {
                    make.top.equalTo(titleLabel.isHidden ? kTop : titleLabel.snp.bottom).offset(kGap)
                }
                make.left.equalTo(leftBtn.snp.right).offset(kGap)
                make.right.equalToSuperview().offset(-kHMargin)
                make.bottom.equalToSuperview().offset(-kBottom)
                make.height.equalTo(kBtnHeight)
            }
        }
    }
    
    // MARK: - 按钮事件
    @objc private func leftBtnClick() {
        leftAction?()
        dismiss()
    }
    
    @objc private func rightBtnClick() {
        rightAction?()
        dismiss()
    }
    
    // MARK: - 显示/消失
    func show() {
        guard let window = UIApplication.shared.dt_mainWindow else { return }
        window.addSubview(self)
        
        self.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 弹出动画
        containerView.alpha = 0
        containerView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.animate(withDuration: 0.25) {
            self.containerView.alpha = 1
            self.containerView.transform = .identity
        }
    }
    
    private func dismiss() {
        UIView.animate(withDuration: 0.2, animations: {
            self.containerView.alpha = 0
            self.containerView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
        }
    }
}

// MARK: - 便捷调用入口
enum DTAlert {
    static func show(title: String?,content: String?,leftTitle: String?,rightTitle: String,
                     leftAction: (() -> Void)? = nil,
                     rightAction: (() -> Void)? = nil) {
        let alert = DTAlertView(title: title, content: content, leftTitle: leftTitle, rightTitle: rightTitle)
        alert.leftAction = leftAction
        alert.rightAction = rightAction
        alert.show()
    }
}
