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

        guard bounds.width > 0 else { return }

        let count = blocks.count
        var columns = Array(repeating: 0, count: count)
        var columnEndTimes = [CGFloat]()

        for i in 0..<count {
            let start = CGFloat(blocks[i].startHour) + CGFloat(blocks[i].startMinute) / 60.0
            let end   = CGFloat(blocks[i].endHour)   + CGFloat(blocks[i].endMinute)   / 60.0

            var placed = false
            for col in 0..<columnEndTimes.count {
                if columnEndTimes[col] <= start {
                    columns[i] = col
                    columnEndTimes[col] = end
                    placed = true
                    break
                }
            }
            if !placed {
                columns[i] = columnEndTimes.count
                columnEndTimes.append(end)
            }
        }

        var totalCols = Array(repeating: 1, count: count)
        for i in 0..<count {
            let startI = CGFloat(blocks[i].startHour) + CGFloat(blocks[i].startMinute) / 60.0
            let endI   = CGFloat(blocks[i].endHour)   + CGFloat(blocks[i].endMinute)   / 60.0
            var maxCol = columns[i]
            for j in 0..<count {
                guard i != j else { continue }
                let startJ = CGFloat(blocks[j].startHour) + CGFloat(blocks[j].startMinute) / 60.0
                let endJ   = CGFloat(blocks[j].endHour)   + CGFloat(blocks[j].endMinute)   / 60.0
                let overlaps = startI < endJ && startJ < endI
                if overlaps { maxCol = max(maxCol, columns[j]) }
            }
            totalCols[i] = maxCol + 1
        }

        let contentWidth = bounds.width - timeColumnWidth - 16

        for (i, block) in blocks.enumerated() {
            let start = CGFloat(block.startHour) + CGFloat(block.startMinute) / 60.0
            let end   = CGFloat(block.endHour)   + CGFloat(block.endMinute)   / 60.0

            let topY      = (start - CGFloat(startHour)) * hourHeight + 16
            let rawHeight = (end - start) * hourHeight - 2
            let height    = max(rawHeight, 30)

            let colCount    = CGFloat(totalCols[i])
            let columnWidth = contentWidth / colCount
            let leadingOffset = timeColumnWidth + 8 + CGFloat(columns[i]) * columnWidth
            let blockWidth  = columnWidth - 4

            let blockView = makeBlockView(for: block, blockHeight: rawHeight, displayHeight: height)
            
            addSubview(blockView)
            blockViews.append(blockView)
            
            NSLayoutConstraint.activate([
                blockView.topAnchor.constraint(equalTo: topAnchor, constant: topY),
                blockView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leadingOffset),
                blockView.widthAnchor.constraint(equalToConstant: blockWidth),
                blockView.heightAnchor.constraint(greaterThanOrEqualToConstant: height),
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
        
        let hasRoutine = !block.linkedRoutines.isEmpty

        let bar = UIView()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.backgroundColor = isActive ? AppColors.accent : (isPast ? AppColors.primary : AppColors.separator)
        bar.layer.cornerRadius = 2
        container.addSubview(bar)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = AppFonts.semibold(13)
        titleLabel.textColor = isActive ? AppColors.accent : AppColors.primary
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        container.addSubview(titleLabel)

        let timeLabel = UILabel()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = AppFonts.regular(11)
        timeLabel.textColor = AppColors.tertiary
        timeLabel.numberOfLines = 0
        timeLabel.lineBreakMode = .byWordWrapping
        container.addSubview(timeLabel)

        if displayHeight < 44 {
            let titleStr = NSMutableAttributedString()
            if hasRoutine, let icon = UIImage(systemName: "repeat")?
                .withConfiguration(UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold))
                .withTintColor(isActive ? AppColors.accent : AppColors.primary, renderingMode: .alwaysOriginal) {
                let attachment = NSTextAttachment()
                attachment.image = icon
                attachment.bounds = CGRect(x: 0, y: -1.5, width: 11, height: 11)
                titleStr.append(NSAttributedString(attachment: attachment))
                titleStr.append(NSAttributedString(string: " "))
            }
            titleStr.append(NSAttributedString(
                string: (block.title ?? "") + " · ",
                attributes: [.font: AppFonts.semibold(13),
                             .foregroundColor: isActive ? AppColors.accent : AppColors.primary]
            ))
            titleStr.append(NSAttributedString(
                string: block.timeRangeText,
                attributes: [.font: AppFonts.regular(11),
                             .foregroundColor: AppColors.tertiary]
            ))
            titleLabel.attributedText = titleStr
            timeLabel.isHidden = true
        } else {
            if hasRoutine, let icon = UIImage(systemName: "repeat")?
                .withConfiguration(UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold))
                .withTintColor(isActive ? AppColors.accent : AppColors.primary, renderingMode: .alwaysOriginal) {
                let str = NSMutableAttributedString()
                let attachment = NSTextAttachment()
                attachment.image = icon
                attachment.bounds = CGRect(x: 0, y: -1.5, width: 11, height: 11)
                str.append(NSAttributedString(attachment: attachment))
                str.append(NSAttributedString(
                    string: " " + (block.title ?? ""),
                    attributes: [.font: AppFonts.semibold(13),
                                 .foregroundColor: isActive ? AppColors.accent : AppColors.primary]
                ))
                titleLabel.attributedText = str
            } else {
                titleLabel.text = block.title
            }
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
        if Calendar.current.isDateInToday(selectedDate) {
            drawCurrentTimeLine()
        }
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.width > 0, !blocks.isEmpty else { return }
        // Block view'ları zaten varsa yeniden çizme
        if blockViews.isEmpty {
            drawBlocks()
        }
    }

    // MARK: - Actions
    @objc private func blockViewTapped(_ gesture: UITapGestureRecognizer) {
        guard gesture.view?.tag ?? -1 < blocks.count else { return }
        let block = blocks[gesture.view!.tag]
        delegate?.timelineView(self, didTapBlock: block)
    }
}
