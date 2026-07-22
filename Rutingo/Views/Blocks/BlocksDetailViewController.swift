//
//  BlocksDetailViewController.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 30.04.2026.
//

import UIKit

class BlocksDetailViewController: UIViewController {

    // MARK: - Properties
    var block: TimeBlock
    var onDelete: (() -> Void)?
    var onUpdate: ((String, Int, Int, Int, Int) -> Void)?
    private let viewModel: BlocksViewModel
    private var routineCardHeightConstraint: NSLayoutConstraint?
    
    // MARK: - UI
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    // Header card
    private let headerCard: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = AppColors.cardBackground
        v.layer.cornerRadius = Layout.cardCornerRadius
        return v
    }()
    
    private let timeBadge: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = AppColors.secondaryCardBackground
        v.layer.cornerRadius = 14
        return v
    }()
    
    private let timeBadgeIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "clock"))
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.tintColor = AppColors.secondary
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let timeBadgeLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = AppFonts.regular(13)
        l.textColor = AppColors.secondary
        return l
    }()
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = AppFonts.bold(26)
        l.textColor = AppColors.primary
        l.numberOfLines = 0
        return l
    }()
    
    private let durationRow: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let durationIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "hourglass"))
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.tintColor = AppColors.secondary
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let durationLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = AppFonts.regular(13)
        l.textColor = AppColors.secondary
        return l
    }()
    
    private let routinePill: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = AppColors.tagPurpleBackground
        v.layer.cornerRadius = 14
        v.isHidden = true
        return v
    }()
    
    private let routinePillIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "repeat"))
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.tintColor = AppColors.accentPurple
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let routinePillLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = AppFonts.medium(13)
        l.textColor = AppColors.accentPurple
        return l
    }()

    private let statusPill: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 14
        v.isHidden = true
        return v
    }()

    private let statusPillIcon: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let statusPillLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = AppFonts.medium(13)
        return l
    }()
    
    // Stat cards
    private let statRow: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let startCard: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = AppColors.cardBackground
        v.layer.cornerRadius = Layout.cardCornerRadius
        return v
    }()
    
    private let startCardLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = AppFonts.regular(12)
        l.textColor = AppColors.secondary
        l.text = "start_time".localized
        return l
    }()
    
    private let startCardValue: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = AppFonts.bold(20)
        l.textColor = AppColors.primary
        return l
    }()
    
    private let startCardDay: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = AppFonts.regular(12)
        l.textColor = AppColors.secondary
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.7
        return l
    }()
    
    private let endCard: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = AppColors.cardBackground
        v.layer.cornerRadius = Layout.cardCornerRadius
        return v
    }()
    
    private let endCardLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = AppFonts.regular(12)
        l.textColor = AppColors.secondary
        l.text = "end_time".localized
        return l
    }()
    
    private let endCardValue: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = AppFonts.bold(20)
        l.textColor = AppColors.primary
        return l
    }()
    
    private let endCardDay: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = AppFonts.regular(12)
        l.textColor = AppColors.secondary
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.7
        return l
    }()
    
    // Routine action card
    private let routineActionCard: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = AppColors.cardBackground
        v.layer.cornerRadius = Layout.cardCornerRadius
        v.isHidden = true
        return v
    }()
    
    private let routineActionIcon: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = AppColors.tagPurpleBackground
        v.layer.cornerRadius = 8
        return v
    }()
    
    private let routineActionIconImage: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "repeat"))
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.tintColor = AppColors.accentPurple
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let routineActionTitle: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = AppFonts.medium(15)
        l.textColor = AppColors.primary
        return l
    }()
    
    private let routineActionSub: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = AppFonts.regular(12)
        l.textColor = AppColors.secondary
        l.text = "linked_routine".localized
        return l
    }()
    
    private let routineActionChevron: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.tintColor = AppColors.secondary
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    // Delete card
    private let deleteCard: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = AppColors.cardBackground
        v.layer.cornerRadius = Layout.cardCornerRadius
        return v
    }()
    
    private let deleteLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = AppFonts.semibold(15)
        l.textColor = .systemRed
        l.textAlignment = .center
        return l
    }()

    // MARK: - Init
    init(block: TimeBlock, viewModel: BlocksViewModel) {
        self.block = block
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        setupNavigationBar()
        setupUI()
        configure()

        let routineTap = UITapGestureRecognizer(target: self, action: #selector(goToRoutineTapped))
        routineActionCard.addGestureRecognizer(routineTap)
        routineActionCard.isUserInteractionEnabled = true

        let deleteTap = UITapGestureRecognizer(target: self, action: #selector(deleteTapped))
        deleteCard.addGestureRecognizer(deleteTap)
        deleteCard.isUserInteractionEnabled = true
    }
    
    // MARK: - Setup
    private func setupNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
        if !block.isGeneratedFromRoutine {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "edit".localized,
                style: .plain,
                target: self,
                action: #selector(editTapped)
            )
            navigationItem.rightBarButtonItem?.tintColor = AppColors.primary
        }
    }
    
    private func setupUI() {
        addSubviews()
        setupConstraints()
    }
    
    private func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Header card
        contentView.addSubview(headerCard)
        headerCard.addSubview(timeBadge)
        timeBadge.addSubview(timeBadgeIcon)
        timeBadge.addSubview(timeBadgeLabel)
        headerCard.addSubview(titleLabel)
        headerCard.addSubview(durationRow)
        durationRow.addSubview(durationIcon)
        durationRow.addSubview(durationLabel)
        headerCard.addSubview(routinePill)
        routinePill.addSubview(routinePillIcon)
        routinePill.addSubview(routinePillLabel)
        headerCard.addSubview(statusPill)
        statusPill.addSubview(statusPillIcon)
        statusPill.addSubview(statusPillLabel)
        
        // Stat row
        contentView.addSubview(statRow)
        statRow.addSubview(startCard)
        startCard.addSubview(startCardLabel)
        startCard.addSubview(startCardValue)
        startCard.addSubview(startCardDay)
        statRow.addSubview(endCard)
        endCard.addSubview(endCardLabel)
        endCard.addSubview(endCardValue)
        endCard.addSubview(endCardDay)

        // Routine action
        contentView.addSubview(routineActionCard)
        routineActionCard.addSubview(routineActionIcon)
        routineActionIcon.addSubview(routineActionIconImage)
        routineActionCard.addSubview(routineActionTitle)
        routineActionCard.addSubview(routineActionSub)
        routineActionCard.addSubview(routineActionChevron)

        // Delete
        contentView.addSubview(deleteCard)
        deleteCard.addSubview(deleteLabel)
    }
    
    private func setupConstraints() {
        let p: CGFloat  = 20
        let cp: CGFloat = 16

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Header card
            headerCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: p),
            headerCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            headerCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -p),
            
            timeBadge.topAnchor.constraint(equalTo: headerCard.topAnchor, constant: cp),
            timeBadge.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: cp),
            timeBadge.heightAnchor.constraint(equalToConstant: 28),
            
            timeBadgeIcon.leadingAnchor.constraint(equalTo: timeBadge.leadingAnchor, constant: 8),
            timeBadgeIcon.centerYAnchor.constraint(equalTo: timeBadge.centerYAnchor),
            timeBadgeIcon.widthAnchor.constraint(equalToConstant: 14),
            timeBadgeIcon.heightAnchor.constraint(equalToConstant: 14),
            
            timeBadgeLabel.leadingAnchor.constraint(equalTo: timeBadgeIcon.trailingAnchor, constant: 5),
            timeBadgeLabel.trailingAnchor.constraint(equalTo: timeBadge.trailingAnchor, constant: -8),
            timeBadgeLabel.centerYAnchor.constraint(equalTo: timeBadge.centerYAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: timeBadge.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: cp),
            titleLabel.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: -cp),
            
            durationRow.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            durationRow.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: cp),
            durationRow.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: -cp),
            durationRow.heightAnchor.constraint(equalToConstant: 20),
            
            durationIcon.leadingAnchor.constraint(equalTo: durationRow.leadingAnchor),
            durationIcon.centerYAnchor.constraint(equalTo: durationRow.centerYAnchor),
            durationIcon.widthAnchor.constraint(equalToConstant: 14),
            durationIcon.heightAnchor.constraint(equalToConstant: 14),
            
            durationLabel.leadingAnchor.constraint(equalTo: durationIcon.trailingAnchor, constant: 5),
            durationLabel.centerYAnchor.constraint(equalTo: durationRow.centerYAnchor),
            
            routinePill.topAnchor.constraint(equalTo: durationRow.bottomAnchor, constant: 12),
            routinePill.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: cp),
            routinePill.heightAnchor.constraint(equalToConstant: 28),
            routinePill.bottomAnchor.constraint(equalTo: headerCard.bottomAnchor, constant: -cp),
            
            routinePillIcon.leadingAnchor.constraint(equalTo: routinePill.leadingAnchor, constant: 8),
            routinePillIcon.centerYAnchor.constraint(equalTo: routinePill.centerYAnchor),
            routinePillIcon.widthAnchor.constraint(equalToConstant: 14),
            routinePillIcon.heightAnchor.constraint(equalToConstant: 14),
            
            routinePillLabel.leadingAnchor.constraint(equalTo: routinePillIcon.trailingAnchor, constant: 5),
            routinePillLabel.trailingAnchor.constraint(equalTo: routinePill.trailingAnchor, constant: -8),
            routinePillLabel.centerYAnchor.constraint(equalTo: routinePill.centerYAnchor),

            statusPill.leadingAnchor.constraint(equalTo: routinePill.trailingAnchor, constant: 8),
            statusPill.centerYAnchor.constraint(equalTo: routinePill.centerYAnchor),
            statusPill.heightAnchor.constraint(equalToConstant: 28),

            statusPillIcon.leadingAnchor.constraint(equalTo: statusPill.leadingAnchor, constant: 8),
            statusPillIcon.centerYAnchor.constraint(equalTo: statusPill.centerYAnchor),
            statusPillIcon.widthAnchor.constraint(equalToConstant: 14),
            statusPillIcon.heightAnchor.constraint(equalToConstant: 14),

            statusPillLabel.leadingAnchor.constraint(equalTo: statusPillIcon.trailingAnchor, constant: 5),
            statusPillLabel.trailingAnchor.constraint(equalTo: statusPill.trailingAnchor, constant: -8),
            statusPillLabel.centerYAnchor.constraint(equalTo: statusPill.centerYAnchor),

            // Stat row
            statRow.topAnchor.constraint(equalTo: headerCard.bottomAnchor, constant: 12),
            statRow.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            statRow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -p),
            statRow.heightAnchor.constraint(equalToConstant: 90),
            
            startCard.topAnchor.constraint(equalTo: statRow.topAnchor),
            startCard.leadingAnchor.constraint(equalTo: statRow.leadingAnchor),
            startCard.widthAnchor.constraint(equalTo: statRow.widthAnchor, multiplier: 0.5, constant: -6),
            startCard.bottomAnchor.constraint(equalTo: statRow.bottomAnchor),
            
            startCardLabel.topAnchor.constraint(equalTo: startCard.topAnchor, constant: cp),
            startCardLabel.leadingAnchor.constraint(equalTo: startCard.leadingAnchor, constant: cp),
            
            startCardValue.topAnchor.constraint(equalTo: startCardLabel.bottomAnchor, constant: 4),
            startCardValue.leadingAnchor.constraint(equalTo: startCard.leadingAnchor, constant: cp),
            
            startCardDay.topAnchor.constraint(equalTo: startCardValue.bottomAnchor, constant: 2),
            startCardDay.leadingAnchor.constraint(equalTo: startCard.leadingAnchor, constant: cp),
            
            endCard.topAnchor.constraint(equalTo: statRow.topAnchor),
            endCard.trailingAnchor.constraint(equalTo: statRow.trailingAnchor),
            endCard.widthAnchor.constraint(equalTo: statRow.widthAnchor, multiplier: 0.5, constant: -6),
            endCard.bottomAnchor.constraint(equalTo: statRow.bottomAnchor),
            
            endCardLabel.topAnchor.constraint(equalTo: endCard.topAnchor, constant: cp),
            endCardLabel.leadingAnchor.constraint(equalTo: endCard.leadingAnchor, constant: cp),
            
            endCardValue.topAnchor.constraint(equalTo: endCardLabel.bottomAnchor, constant: 4),
            endCardValue.leadingAnchor.constraint(equalTo: endCard.leadingAnchor, constant: cp),
            
            endCardDay.topAnchor.constraint(equalTo: endCardValue.bottomAnchor, constant: 2),
            endCardDay.leadingAnchor.constraint(equalTo: endCard.leadingAnchor, constant: cp),
            
            // Routine action card
            routineActionCard.topAnchor.constraint(equalTo: statRow.bottomAnchor, constant: 12),
            routineActionCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            routineActionCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -p),
            routineActionCard.heightAnchor.constraint(equalToConstant: 60),
            
            routineActionIcon.leadingAnchor.constraint(equalTo: routineActionCard.leadingAnchor, constant: cp),
            routineActionIcon.centerYAnchor.constraint(equalTo: routineActionCard.centerYAnchor),
            routineActionIcon.widthAnchor.constraint(equalToConstant: 32),
            routineActionIcon.heightAnchor.constraint(equalToConstant: 32),
            
            routineActionIconImage.centerXAnchor.constraint(equalTo: routineActionIcon.centerXAnchor),
            routineActionIconImage.centerYAnchor.constraint(equalTo: routineActionIcon.centerYAnchor),
            routineActionIconImage.widthAnchor.constraint(equalToConstant: 16),
            routineActionIconImage.heightAnchor.constraint(equalToConstant: 16),

            routineActionTitle.leadingAnchor.constraint(equalTo: routineActionIcon.trailingAnchor, constant: 12),
            routineActionTitle.topAnchor.constraint(equalTo: routineActionCard.topAnchor, constant: 12),
            routineActionTitle.trailingAnchor.constraint(equalTo: routineActionChevron.leadingAnchor, constant: -8),

            routineActionSub.leadingAnchor.constraint(equalTo: routineActionIcon.trailingAnchor, constant: 12),
            routineActionSub.topAnchor.constraint(equalTo: routineActionTitle.bottomAnchor, constant: 2),

            routineActionChevron.trailingAnchor.constraint(equalTo: routineActionCard.trailingAnchor, constant: -cp),
            routineActionChevron.centerYAnchor.constraint(equalTo: routineActionCard.centerYAnchor),
            routineActionChevron.widthAnchor.constraint(equalToConstant: 12),
            routineActionChevron.heightAnchor.constraint(equalToConstant: 12),
            
            // Delete card
            deleteCard.topAnchor.constraint(equalTo: routineActionCard.bottomAnchor, constant: 12),
            deleteCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            deleteCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -p),
            deleteCard.heightAnchor.constraint(equalToConstant: 50),
            deleteCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -p),
            
            deleteLabel.centerXAnchor.constraint(equalTo: deleteCard.centerXAnchor),
            deleteLabel.centerYAnchor.constraint(equalTo: deleteCard.centerYAnchor),
        ])

        routineCardHeightConstraint = routineActionCard.heightAnchor.constraint(equalToConstant: 0)
    }
    
    // MARK: - Configure
    private func configure() {
        // Time badge
        timeBadgeLabel.text = block.timeRangeText
        
        // Title
        titleLabel.text = block.title
        
        // Duration
        durationLabel.text = viewModel.duration(for: block)

        let dayName = DateHelper.shared.formattedDateShort(viewModel.selectedDate)

        // Stat cards
        startCardValue.text = String(format: "%02d:%02d", block.startHour, block.startMinute)
        startCardDay.text = dayName
        endCardValue.text = String(format: "%02d:%02d", block.endHour, block.endMinute)
        endCardDay.text = dayName

        // Routine pill & action card
        let routineName: String?
        if block.isGeneratedFromRoutine {
            routineName = block.sourceRoutineID.flatMap {
                viewModel.routine(withID: $0)?.name
            }
        } else {
            routineName = block.linkedRoutines.first?.name
        }

        if let name = routineName {
            routinePillLabel.text = name
            routinePill.isHidden = false
            routineActionTitle.text = name
            routineActionCard.isHidden = false
            routineCardHeightConstraint?.isActive = false
        } else {
            routinePill.isHidden = true
            routineActionCard.isHidden = true
            routineCardHeightConstraint?.isActive = true
        }
        
        routinePill.layoutIfNeeded()
        routinePill.layer.cornerRadius = routinePill.bounds.height / 2

        switch block.routineStatus {
        case .completed:
            statusPill.isHidden = false
            statusPill.backgroundColor = AppColors.tagGreenBackground
            statusPillIcon.image = UIImage(systemName: "checkmark.circle.fill")
            statusPillIcon.tintColor = AppColors.tagGreenText
            statusPillLabel.textColor = AppColors.tagGreenText
            statusPillLabel.text = "block_status_completed".localized
        case .skipped:
            statusPill.isHidden = false
            statusPill.backgroundColor = AppColors.tagOrangeBackground
            statusPillIcon.image = UIImage(systemName: "forward.circle.fill")
            statusPillIcon.tintColor = AppColors.tagOrangeText
            statusPillLabel.textColor = AppColors.tagOrangeText
            statusPillLabel.text = "block_status_skipped".localized
        case .missed:
            statusPill.isHidden = false
            statusPill.backgroundColor = AppColors.tagRedBackground
            statusPillIcon.image = UIImage(systemName: "xmark.circle.fill")
            statusPillIcon.tintColor = AppColors.tagRedText
            statusPillLabel.textColor = AppColors.tagRedText
            statusPillLabel.text = "block_status_missed".localized
        case .pending, .none:
            statusPill.isHidden = true
        }

        statusPill.layoutIfNeeded()
        statusPill.layer.cornerRadius = statusPill.bounds.height / 2

        deleteLabel.text = block.isGeneratedFromRoutine ? "skip".localized : "delete_block".localized

        // Skipping a future routine occurrence is disabled for now (see BlocksViewModel.skipBlock) —
        // hide the action entirely rather than let it silently no-op on tap.
        let isFutureGeneratedBlock = block.isGeneratedFromRoutine
            && (block.date.map { $0 > DateHelper.shared.startOfDay() } ?? false)
        deleteCard.isHidden = isFutureGeneratedBlock
    }
    
    // MARK: - Actions
    @objc private func goToRoutineTapped() {
        let routineID: UUID?
        if block.isGeneratedFromRoutine {
            routineID = block.sourceRoutineID
        } else {
            routineID = block.linkedRoutines.first?.id
        }
        guard let id = routineID else { return }
        let routinesVM = RoutinesViewModel()
        guard let routine = routinesVM.routine(withID: id) else { return }
        let detailVC = RoutineDetailViewController(routine: routine, viewModel: routinesVM, initialDate: block.date)
        navigationController?.pushViewController(detailVC, animated: true)
    }

    @objc private func editTapped() {
        let addVC = AddBlockViewController(viewModel: viewModel)
        addVC.configure(
            title: block.title ?? "",
            startHour:    Int(block.startHour),
            startMinute:  Int(block.startMinute),
            endHour:      Int(block.endHour),
            endMinute:    Int(block.endMinute),
            linkedRoutine: block.linkedRoutines.first
        )
        addVC.onUpdate = { [weak self] title, startHour, startMinute, endHour, endMinute, newLinkedRoutine in
            guard let self else { return }
            self.viewModel.updateBlockWithRoutine(
                self.block, title: title,
                startHour: startHour, startMinute: startMinute,
                endHour: endHour, endMinute: endMinute,
                newLinkedRoutine: newLinkedRoutine
            ) {
                self.configure()
            }
            self.onUpdate?(title, startHour, startMinute, endHour, endMinute)
        }
        let navVC = UINavigationController(rootViewController: addVC)
        present(navVC, animated: true)
    }
    
    @objc private func deleteTapped() {
        if block.isGeneratedFromRoutine {
            let alert = UIAlertController(
                title: block.title,
                message: "skip_routine_confirm_message".localized,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel))
            alert.addAction(UIAlertAction(title: "skip".localized, style: .destructive) { [weak self] _ in
                guard let self else { return }
                self.viewModel.skipBlock(self.block) {
                    self.onDelete?()
                    self.navigationController?.popViewController(animated: true)
                }
            })
            present(alert, animated: true)
        } else {
            let alert = UIAlertController(
                title: "delete_block".localized,
                message: "delete_block_message".localized,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel))
            alert.addAction(UIAlertAction(title: "delete".localized, style: .destructive) { [weak self] _ in
                guard let self else { return }
                self.viewModel.deleteBlock(self.block) {
                    self.onDelete?()
                    self.navigationController?.popViewController(animated: true)
                }
            })
            present(alert, animated: true)
        }
    }
}
