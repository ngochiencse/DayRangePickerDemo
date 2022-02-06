import UIKit
import RxSwift
import JTAppleCalendar
import NSObject_Rx

class DateCell: JTACDayCell {
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var selectedView: UIView!
    
    var viewModel: DateCellViewModel? {
        willSet {
            unbindFromViewModel()
        }
        didSet {
            bindToViewModel()
        }
    }
    var disposables: [Disposable] = []

    private func bindToViewModel() {
        guard let viewModel = viewModel else { return }
        
        do {
            let disposable = viewModel.dateText.bind(to: dateLabel.rx.text)
            disposable.disposed(by: rx.disposeBag)
            disposables.append(disposable)
        }

        do {
            let disposable = viewModel.dateBelongsTo.map { (dateBelongsTo) -> Bool in
                guard let dateBelongsTo = dateBelongsTo else { return  true}
                return (dateBelongsTo != .thisMonth)
            }.bind(to: dateLabel.rx.isHidden)
            disposable.disposed(by: rx.disposeBag)
            disposables.append(disposable)
        }

        do {
            let disposable = viewModel.selectedPosition.observe(on: MainScheduler.instance)
                .subscribe(onNext: {[weak self] (selectedPosition) in
                    guard let self = self else { return }
                    switch selectedPosition {
                    case .left:
                        self.selectedView.layer.cornerRadius = 20
                        self.selectedView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
                        self.selectedView.isHidden = false
                    case .middle:
                        self.selectedView.layer.cornerRadius = 0
                        self.selectedView.layer.maskedCorners = []
                        self.selectedView.isHidden = false
                    case .right:
                        self.selectedView.layer.cornerRadius = 20
                        self.selectedView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
                        self.selectedView.isHidden = false
                    case .full:
                        self.selectedView.layer.cornerRadius = 20
                        self.selectedView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
                        self.selectedView.isHidden = false
                    default:
                        self.selectedView.isHidden = true
                    }
                })
            disposable.disposed(by: rx.disposeBag)
            disposables.append(disposable)
        }

        do {
            let disposable = viewModel.dateBelongsTo.observe(on: MainScheduler.instance)
                .subscribe(onNext: {[weak self] (dateBelongsTo) in
                    guard let self = self else { return }
                    self.displayTextColor(dateBelongsTo: dateBelongsTo)
                })
            disposable.disposed(by: rx.disposeBag)
            disposables.append(disposable)
        }
    }

    private func displayTextColor(dateBelongsTo: DateOwner?) {
        if dateBelongsTo == .thisMonth {
            dateLabel.textColor = UIColor.black
        } else {
            dateLabel.textColor = UIColor.gray
        }
    }

    private func unbindFromViewModel() {
        disposables.forEach { (ele) in
            ele.dispose()
        }
        disposables.removeAll()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
