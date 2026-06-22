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
    private var goToRoutineHeightConstraint: NSLayoutConstraint?
    private var linkedRoutineLabelHeightConstraint: NSLayoutConstraint?
    
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
    
    private let infoCard: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = AppColors.cardBackground
        v.layer.cornerRadius = Layout.cardCornerRadius
        return v
    }()
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = AppFonts.bold(24)
        l.textColor = AppColors.primary
        l.numberOfLines = 1
        return l
    }()
    
    private let timeLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = AppFonts.regular(15)
        l.textColor = AppColors.secondary
        return l
    }()
    
    private let linkedRoutineLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = AppFonts.medium(13)
        l.textColor = AppColors.accentPurple
        l.backgroundColor = AppColors.tagPurpleBackground
        l.layer.cornerRadius = Layout.pillRadius
        l.clipsToBounds = true
        l.textAlignment = .center
        l.isHidden = true
        return l
    }()

    private let goToRoutineButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.backgroundColor = AppColors.cardBackground
        b.layer.cornerRadius = Layout.cardCornerRadius
        var config = UIButton.Configuration.plain()
        config.title = "go_to_routine".localized
        config.baseForegroundColor = AppColors.primary
        config.image = UIImage(systemName: "chevron.right")
        config.imagePlacement = .trailing
        config.imagePadding = 8
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { container in
            var c = container
            c.font = AppFonts.semibold(15)
            return c
        }
        b.configuration = config
        b.isHidden = true
        return b
    }()
    
    private let deleteButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.titleLabel?.font = AppFonts.semibold(16)
        b.setTitleColor(.systemRed, for: .normal)
        return b
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
        goToRoutineButton.addTarget(self, action: #selector(goToRoutineTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
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
        
        contentView.addSubview(infoCard)
        infoCard.addSubview(titleLabel)
        infoCard.addSubview(timeLabel)
        infoCard.addSubview(linkedRoutineLabel)
        
        contentView.addSubview(goToRoutineButton)
        contentView.addSubview(deleteButton)
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

            infoCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: p),
            infoCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            infoCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -p),

            titleLabel.topAnchor.constraint(equalTo: infoCard.topAnchor, constant: cp),
            titleLabel.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: cp),
            titleLabel.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -cp),

            timeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            timeLabel.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: cp),
            timeLabel.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -cp),

            linkedRoutineLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 10),
            linkedRoutineLabel.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: cp),
            linkedRoutineLabel.trailingAnchor.constraint(lessThanOrEqualTo: infoCard.trailingAnchor, constant: -cp),
            linkedRoutineLabel.bottomAnchor.constraint(equalTo: infoCard.bottomAnchor, constant: -cp),

            goToRoutineButton.topAnchor.constraint(equalTo: infoCard.bottomAnchor, constant: 12),
            goToRoutineButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            goToRoutineButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -p),

            deleteButton.topAnchor.constraint(equalTo: goToRoutineButton.bottomAnchor, constant: 8),
            deleteButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            deleteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -p),
        ])

        let hGoTo = goToRoutineButton.heightAnchor.constraint(equalToConstant: 0)
        goToRoutineHeightConstraint = hGoTo

        let hLinked = linkedRoutineLabel.heightAnchor.constraint(equalToConstant: 0)
        linkedRoutineLabelHeightConstraint = hLinked
    }
    
    // MARK: - Configure
    private func configure() {
        titleLabel.text = block.title
        timeLabel.text  = block.timeRangeText
        
        let routineName: String?
        if block.isGeneratedFromRoutine {
            if let rid = block.sourceRoutineID {
                routineName = viewModel.routine(withID: rid)?.name
            } else {
                routineName = nil
            }
        } else {
            routineName = block.linkedRoutines.first?.name
        }

        if let name = routineName {
            linkedRoutineLabel.text    = "  \(name)  "
            linkedRoutineLabel.isHidden = false
            linkedRoutineLabelHeightConstraint?.isActive = false
            linkedRoutineLabel.layoutIfNeeded()
            linkedRoutineLabel.layer.cornerRadius = linkedRoutineLabel.bounds.height / 2
        } else {
            linkedRoutineLabel.isHidden = true
            linkedRoutineLabelHeightConstraint?.isActive = true
        }
        
        let buttonTitle = block.isGeneratedFromRoutine ? "skip".localized : "delete_block".localized
        deleteButton.setTitle(buttonTitle, for: .normal)
        
        let hasLinked = block.isGeneratedFromRoutine || block.linkedRoutines.first != nil
        goToRoutineButton.isHidden = !hasLinked
        goToRoutineHeightConstraint?.isActive = !hasLinked
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
        let detailVC = RoutineDetailViewController(routine: routine, viewModel: routinesVM)
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
