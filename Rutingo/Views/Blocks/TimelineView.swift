//
//  TimelineView.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 28.04.2026.
//

import UIKit

protocol TimelineViewDelegate: AnyObject {
    func timelineView(_ view: TimelineView, didTapBlock block: TimeBlock)
}

class TimelineView: UIView {

    // MARK: - Constants
    var hourHeight: CGFloat = 60 {
        didSet { redraw() }
    }
    private let timeColumnWidth: CGFloat = 52
    private let startHour: Int = 0
    private let endHour: Int   = 24

    // MARK: - Properties
    weak var delegate: TimelineViewDelegate?
    var blocks: [TimeBlock] = [] {
        didSet { redraw() }
    }
    
    var selectedDate: Date = Date() {
        didSet { redraw() }
    }

    private var blockViews: [UIView] = []
    private var currentTimeLineView: UIView?
    private var heightConstraint: NSLayoutConstraint?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup
    private func setup() {
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false

        let h = NSLayoutConstraint(
            item: self, attribute: .height,
            relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute,
            multiplier: 1,
            constant: totalHeight
        )
        heightConstraint = h
        addConstraint(h)

        drawTimeLines()
        if Calendar.current.isDateInToday(selectedDate) {
            drawCurrentTimeLine()
        }
    }

    private var totalHeight: CGFloat {
        CGFloat(endHour - startHour) * hourHeight + 32
    }

    // MARK: - Drawing
    private func drawTimeLines() {
        for hour in startHour...endHour {
            let y = CGFloat(hour - startHour) * hourHeight + 16

            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = String(format: "%02d:00", hour)
            label.font = AppFonts.regular(11)
            label.textColor = AppColors.tertiary
            label.textAlignment = .right
            addSubview(label)

            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
                label.widthAnchor.constraint(equalToConstant: timeColumnWidth - 8),
                label.topAnchor.constraint(equalTo: topAnchor, constant: y - 7),
            ])

            let line = UIView()
            line.translatesAutoresizingMaskIntoConstraints = false
            line.backgroundColor = AppColors.separator
            addSubview(line)

            NSLayoutConstraint.activate([
                line.leadingAnchor.constraint(equalTo: leadingAnchor, constant: timeColumnWidth),
                line.trailingAnchor.constraint(equalTo: trailingAnchor),
                line.topAnchor.constraint(equalTo: topAnchor, constant: y),
                line.heightAnchor.constraint(equalToConstant: 0.5),
            ])
        }
    }

    func drawBlocks() {
        blockViews.forEach { $0.removeFromSuperview() }
        blockViews.removeAll()

        for block in blocks {
            let startDecimal = CGFloat(block.startHour) + CGFloat(block.startMinute) / 60.0
            let endDecimal = CGFloat(block.endHour) + CGFloat(block.endMinute) / 60.0
            let topY = (startDecimal - CGFloat(startHour)) * hourHeight + 16
            
            let rawHeight = (endDecimal - startDecimal) * hourHeight - 2
            let height = max(rawHeight, 30)
            let blockView = makeBlockView(for: block, blockHeight: rawHeight, displayHeight: height)
            
            addSubview(blockView)
            blockViews.append(blockView)
            
            NSLayoutConstraint.activate([
                blockView.topAnchor.constraint(equalTo: topAnchor, constant: topY),
                blockView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: timeColumnWidth + 8),
                blockView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
                blockView.heightAnchor.constraint(equalToConstant: height),
            ])
        }
    }

    func drawCurrentTimeLine() {
        currentTimeLineView?.removeFromSuperview()

        let now = Date()
        let hour = Calendar.current.component(.hour, from: now)
        let minute = Calendar.current.component(.minute, from: now)
        let y = CGFloat(hour - startHour) * hourHeight + CGFloat(minute) / 60.0 * hourHeight + 16

        let dot = UIView()
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.backgroundColor = AppColors.accent
        dot.layer.cornerRadius = 4
        addSubview(dot)

        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = AppColors.accent
        addSubview(line)
        currentTimeLineView = line

        NSLayoutConstraint.activate([
            dot.widthAnchor.constraint(equalToConstant: 8),
            dot.heightAnchor.constraint(equalToConstant: 8),
            dot.leadingAnchor.constraint(equalTo: leadingAnchor, constant: timeColumnWidth - 4),
            dot.centerYAnchor.constraint(equalTo: topAnchor, constant: y),

            line.leadingAnchor.constraint(equalTo: dot.trailingAnchor),
            line.trailingAnchor.constraint(equalTo: trailingAnchor),
            line.heightAnchor.constraint(equalToConstant: 1.5),
            line.centerYAnchor.constraint(equalTo: topAnchor, constant: y),
        ])
    }

    private func makeBlockView(for block: TimeBlock, blockHeight: CGFloat, displayHeight: CGFloat) -> UIView {
        let isToday = Calendar.current.isDateInToday(selectedDate)
        let currentHour = Calendar.current.component(.hour, from: Date())
        let currentMin = Calendar.current.component(.minute, from: Date())
        let nowDecimal = Double(currentHour) + Double(currentMin) / 60.0
        let startDecimal = Double(block.startHour) + Double(block.startMinute) / 60.0
        let endDecimal = Double(block.endHour) + Double(block.endMinute) / 60.0
        let isPast = !isToday || endDecimal <= nowDecimal
        let isActive = isToday && startDecimal <= nowDecimal && nowDecimal < endDecimal

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = isActive ? AppColors.accent.withAlphaComponent(0.12) : AppColors.cardBackground
        container.layer.cornerRadius = 10
        container.layer.masksToBounds = true

        let bar = UIView()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.backgroundColor = isActive ? AppColors.accent : (isPast ? AppColors.primary : AppColors.separator)
        bar.layer.cornerRadius = 2
        container.addSubview(bar)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = AppFonts.semibold(13)
        titleLabel.textColor = isActive ? AppColors.accent : AppColors.primary
        titleLabel.numberOfLines = 1
        container.addSubview(titleLabel)

        let timeLabel = UILabel()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = AppFonts.regular(11)
        timeLabel.textColor = AppColors.tertiary
        container.addSubview(timeLabel)

        if displayHeight < 44 {
            let title = NSMutableAttributedString(
                string: (block.title ?? "") + " · ",
                attributes: [
                    .font: AppFonts.semibold(13),
                    .foregroundColor: isActive ? AppColors.accent : AppColors.primary
                ]
            )
            let time = NSAttributedString(
                string: block.timeRangeText,
                attributes: [
                    .font: AppFonts.regular(11),
                    .foregroundColor: AppColors.tertiary
                ]
            )
            title.append(time)
            titleLabel.attributedText = title
            timeLabel.isHidden = true
        } else {
            titleLabel.text = block.title
            timeLabel.text = block.timeRangeText
            timeLabel.isHidden = false
        }
        
        if displayHeight < 44 {
            NSLayoutConstraint.activate([
                bar.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
                bar.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
                bar.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
                bar.widthAnchor.constraint(equalToConstant: 3),

                titleLabel.leadingAnchor.constraint(equalTo: bar.trailingAnchor, constant: 8),
                titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
            ])
        } else {
            NSLayoutConstraint.activate([
                bar.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
                bar.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
                bar.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
                bar.widthAnchor.constraint(equalToConstant: 3),
                
                titleLabel.leadingAnchor.constraint(equalTo: bar.trailingAnchor, constant: 8),
                titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
                titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
                
                timeLabel.leadingAnchor.constraint(equalTo: bar.trailingAnchor, constant: 8),
                timeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
                timeLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
                timeLabel.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -8),
            ])
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(blockViewTapped(_:)))
        container.addGestureRecognizer(tap)

        if let index = blocks.firstIndex(where: { $0.id == block.id }) {
            container.tag = index
        }

        return container
    }

    // MARK: - Redraw
    private func redraw() {
        subviews.forEach { $0.removeFromSuperview() }
        blockViews.removeAll()
        currentTimeLineView = nil
        heightConstraint?.constant = totalHeight
        drawTimeLines()
        drawBlocks()
        if Calendar.current.isDateInToday(selectedDate) {
            drawCurrentTimeLine()
        }
    }

    // MARK: - Actions
    @objc private func blockViewTapped(_ gesture: UITapGestureRecognizer) {
        guard gesture.view?.tag ?? -1 < blocks.count else { return }
        let block = blocks[gesture.view!.tag]
        delegate?.timelineView(self, didTapBlock: block)
    }
}
