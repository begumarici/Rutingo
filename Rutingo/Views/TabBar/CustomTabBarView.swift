//
//  CustomTabBarView.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 12.01.2026.
//

import UIKit

protocol CustomTabBarDelegate: AnyObject {
    func didSelectTab(at index: Int)
    func didTapAddButton()
}

class CustomTabBarView: UIView {
    
    weak var delegate: CustomTabBarDelegate?
    
    private var buttons: [UIButton] = []
    private var selectedIndex: Int = 0
    
    // MARK: - UI Components
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.spacing = 32
        return stack
    }()
    
    private let selectionIndicator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = AppColors.primary
        view.layer.cornerRadius = 22
        return view
    }()
    
    private var indicatorCenterXConstraint: NSLayoutConstraint?
    
    // MARK: - Initialization
    init(items: [String]) {
        super.init(frame: .zero)
        setupUI()
        createButtons(from: items)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = AppColors.cardBackground
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(selectionIndicator)
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor), 
            stackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            
            selectionIndicator.widthAnchor.constraint(equalToConstant: 64),
            selectionIndicator.heightAnchor.constraint(equalToConstant: 44),
            selectionIndicator.centerYAnchor.constraint(equalTo: stackView.centerYAnchor)
        ])
    }
    
    private func createButtons(from items: [String]) {
        for (index, icon) in items.enumerated() {
            let button = createTabButton(icon: icon, tag: index)
            buttons.append(button)
            stackView.addArrangedSubview(button)
        }
        
        layoutIfNeeded()
        if let firstButton = buttons.first {
            indicatorCenterXConstraint = selectionIndicator.centerXAnchor.constraint(equalTo: firstButton.centerXAnchor)
            indicatorCenterXConstraint?.isActive = true
        }
        
        updateButtonState(at: 0)
    }
    
    private func createTabButton(icon: String, tag: Int) -> UIButton {
        let button = UIButton(type: .custom)
        button.tag = tag
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: icon)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = AppColors.secondary
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.isUserInteractionEnabled = false
        iconImageView.tag = 100
        
        button.addSubview(iconImageView)
        
        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        button.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
        
        return button
    }
    
    // MARK: - Actions
    @objc private func tabButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        if index == 0 && selectedIndex == 0 {
            delegate?.didTapAddButton()
            return
        }
        
        selectTab(at: index)
        delegate?.didSelectTab(at: index)
    }
    
    func selectTab(at index: Int) {
        guard index != selectedIndex else { return }
        
        selectedIndex = index
        
        indicatorCenterXConstraint?.isActive = false
        indicatorCenterXConstraint = selectionIndicator.centerXAnchor.constraint(equalTo: buttons[index].centerXAnchor)
        indicatorCenterXConstraint?.isActive = true
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
            self.layoutIfNeeded()
            self.updateButtonState(at: index)
        }
    }
    
    private func updateButtonState(at selectedIndex: Int) {
        for (index, button) in buttons.enumerated() {
            let isSelected = (index == selectedIndex)
            
            if let iconView = button.viewWithTag(100) as? UIImageView {
                iconView.tintColor = isSelected ? AppColors.cardBackground : AppColors.secondary
                
                if index == 0 {
                    if isSelected {
                        iconView.image = UIImage(systemName: "plus.circle.fill")
                    } else {
                        iconView.image = UIImage(systemName: "house.fill")
                    }
                }
            }
        }
    }
}
