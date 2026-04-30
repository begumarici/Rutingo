//
//  BlocksViewController.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 28.04.2026.
//

import UIKit

class BlocksViewController: UIViewController {

    // MARK: - Properties
    private let viewModel  = BlocksViewModel()
    private let timelineView = TimelineView()

    private var lastHourHeight: CGFloat = 60
    private let minHourHeight: CGFloat  = 30
    private let maxHourHeight: CGFloat  = 120

    // MARK: - UI
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsVerticalScrollIndicator   = true
        sv.showsHorizontalScrollIndicator = false
        return sv
    }()

    private var hasScrolledToCurrentTime = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        setupNavigationBar()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !hasScrolledToCurrentTime else { return }
        hasScrolledToCurrentTime = true
        scrollToCurrentTime()
    }

    // MARK: - Setup
    private func setupNavigationBar() {
        title = "tab_blocks".localized
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addBlockTapped)
        )
    }

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(timelineView)
        timelineView.delegate = self

        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        scrollView.addGestureRecognizer(pinch)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            timelineView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            timelineView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            timelineView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            timelineView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            timelineView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
        ])
    }

    // MARK: - Data
    private func loadData() {
        viewModel.loadData { [weak self] in
            guard let self else { return }
            timelineView.blocks = viewModel.blocks
            timelineView.drawCurrentTimeLine()
        }
    }

    // MARK: - Scroll
    private func scrollToCurrentTime() {
        let hour   = Calendar.current.component(.hour, from: Date())
        let minute = Calendar.current.component(.minute, from: Date())
        let y      = CGFloat(hour) * timelineView.hourHeight + CGFloat(minute) / 60.0 * timelineView.hourHeight + 16
        let offset = max(0, y - 120)
        scrollView.setContentOffset(CGPoint(x: 0, y: offset), animated: false)
    }

    // MARK: - Pinch
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            lastHourHeight = timelineView.hourHeight

        case .changed:
            let newHeight = (lastHourHeight * gesture.scale)
                .clamped(to: minHourHeight...maxHourHeight)
            guard newHeight != timelineView.hourHeight else { return }

            let currentOffset = scrollView.contentOffset.y
            let currentHour   = currentOffset / timelineView.hourHeight

            timelineView.hourHeight = newHeight

            let newOffset = currentHour * timelineView.hourHeight
            scrollView.setContentOffset(CGPoint(x: 0, y: newOffset), animated: false)

        default:
            break
        }
    }

    // MARK: - Actions
    @objc private func addBlockTapped() {
        let addVC = AddBlockViewController()
        addVC.onSave = { [weak self] title, startHour, endHour in
            self?.viewModel.addBlock(title: title, startHour: startHour, endHour: endHour) {
                self?.timelineView.blocks = self?.viewModel.blocks ?? []
            }
        }
        let navVC = UINavigationController(rootViewController: addVC)
        present(navVC, animated: true)
    }
}

// MARK: - TimelineViewDelegate
extension BlocksViewController: TimelineViewDelegate {
    func timelineView(_ view: TimelineView, didTapBlock block: TimeBlock) {
        // AddBlockViewController
    }
}

// MARK: - Comparable
extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}
