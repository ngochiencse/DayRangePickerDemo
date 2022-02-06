import UIKit
import JTAppleCalendar
import RxSwift

class ViewController: UIViewController {
    @IBOutlet var calendarView: JTACMonthView!
    var viewModel: ViewModel? = ViewModelImpl(startDate: nil, endDate: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCalendarView()
        bindToViewModel()
    }
    
    func setUpCalendarView() {
        calendarView.allowsMultipleSelection = true
        calendarView.allowsRangedSelection = true
        calendarView.calendarDataSource = self
        calendarView.calendarDelegate = self
    }
    
    func bindToViewModel() {
        guard let viewModel = viewModel else { return }

        viewModel.selectedDateRange.observe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] selectedDateRange in
                guard let self = self else { return }
                self.calendarView.deselectAllDates()
                if let selectedStartDate = selectedDateRange?.start {
                    if let selectedEndDate = selectedDateRange?.end {
                        /*
                         triggerSelectionDelegate is true to make viewModel mark
                         indexPath for selectedDateRange to highlightlight
                         cells between selectedDateRange
                         */
                        self.calendarView.selectDates(from: selectedStartDate,
                                                      to: selectedEndDate,
                                                      triggerSelectionDelegate: true,
                                                      keepSelectionIfMultiSelectionAllowed: true)
                    } else {
                        self.calendarView.selectDates([selectedStartDate])
                    }
                }

                // Reload data in order to highlight cell between selectedDateRange
                self.calendarView.reloadData()
            }).disposed(by: rx.disposeBag)

        // Scroll to selected date when first time enter
        viewModel.selectedDateRange
            .observe(on: MainScheduler.instance)
            .take(1)
            .subscribe(onNext: {[weak self] selectedDateRange in
                guard let self = self else { return }
                if let date = selectedDateRange?.start {
                    self.calendarView.scrollToHeaderForDate(date)
                } else if let date = selectedDateRange?.end {
                    self.calendarView.scrollToHeaderForDate(date)
                }
            }).disposed(by: rx.disposeBag)
    }
}

extension ViewController: JTACMonthViewDataSource {
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"

        let startDate = formatter.date(from: "2018 01 01")!
        let endDate = Date()
        return ConfigurationParameters(startDate: startDate, endDate: endDate)
    }
}

extension ViewController: JTACMonthViewDelegate {
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        guard let cell = cell as? DateCell else { return }
        configureCell(cell, cellState: cellState, indexPath: indexPath)
    }

    func configureCell(_ cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        guard let viewModel = viewModel else { return }
        guard let cell = cell as? DateCell  else { return }
        let cellViewModel = cell.viewModel
        cellViewModel?.dateText.accept(cellState.text)
        cellViewModel?.day.accept(cellState.day)
        cellViewModel?.dateBelongsTo.accept(cellState.dateBelongsTo)
        let selectedPosition =
            viewModel.calculateSelectedPosition(at: indexPath,
                                                dateBelongsTo: cellState.dateBelongsTo,
                                                selectedPosition: cellState.selectedPosition())
        cellViewModel?.selectedPosition.accept(selectedPosition)
        cellViewModel?.isSelected.accept(cellState.isSelected)
    }

    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let cell: DateCell! = calendar.dequeueReusableJTAppleCell(
            withReuseIdentifier: "dateCell", for: indexPath) as? DateCell
        guard let viewModel = viewModel else { return cell }
        cell.viewModel = viewModel.cellViewModel(at: indexPath)
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        return cell
    }

    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date,
                  cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        guard let viewModel = viewModel else { return }
        viewModel.didSelectDate(date: date,
                                selectionType: cellState.selectionType,
                                indexPath: indexPath)
        configureCell(cell, cellState: cellState, indexPath: indexPath)
    }

    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date,
                  cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        guard let viewModel = viewModel else { return }
        viewModel.didDeselectDate(date: date,
                                  selectionType: cellState.selectionType,
                                  indexPath: indexPath)
        configureCell(cell, cellState: cellState, indexPath: indexPath)
    }

    func calendar(_ calendar: JTACMonthView, shouldSelectDate date: Date,
                  cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) -> Bool {
        guard let viewModel = viewModel else { return false }
        return viewModel.shouldSelectDate(date,
                                          selectionType: cellState.selectionType,
                                          dateBelongsTo: cellState.dateBelongsTo,
                                          indexPath: indexPath)
    }

    func calendar(_ calendar: JTACMonthView, shouldDeselectDate date: Date,
                  cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) -> Bool {
        guard let viewModel = viewModel else { return false }
        return viewModel.shouldDeselectDate(date,
                                            selectionType: cellState.selectionType,
                                            indexPath: indexPath)
    }
}
