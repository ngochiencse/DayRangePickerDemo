//
//  ViewModelImpl.swift
//  test
//
//  Created by Hien Pham on 2/5/22.
//  Copyright © 2022 AppleInc. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import JTAppleCalendar
import SwiftDate

struct IndexPathRange {
    var start: IndexPath?
    var end: IndexPath?
}

class ViewModelImpl: NSObject, ViewModel {
    let startDate: Date?
    let endDate: Date?
    let selectedDateRange: BehaviorRelay<DateRange?> = BehaviorRelay(value: nil)

    /*
     Store selected index path start and end in order to highlight
     cell between these two index paths
     */
    let selectedIndexPathRange: BehaviorRelay<IndexPathRange?> = BehaviorRelay(value: nil)

    private var cellDict: [IndexPath: DateCellViewModel] = [:]

    init(startDate: Date? = nil, endDate: Date? = nil) {
        let currentDate = Date()
        self.startDate = startDate ?? currentDate.dateAtStartOf(.month)
        self.endDate = endDate ?? currentDate.dateByAdding(1, .year).dateAtEndOf(.month).date
        super.init()
    }

    private func clearDefaultAll() {
        selectedDateRange.accept(nil)
        selectedIndexPathRange.accept(nil)
    }


    func getParameterForCalendar() -> ConfigurationParameters {
        let startDate = self.startDate ?? Date()
        let endDate = self.endDate ?? Date()
        let parameters = ConfigurationParameters(startDate: startDate,
                                                 endDate: endDate,
                                                 numberOfRows: 6,
                                                 calendar: Calendar.current,
                                                 generateInDates: .forAllMonths,
                                                 generateOutDates: .tillEndOfRow,
                                                 firstDayOfWeek: .sunday)
        return parameters
    }

    func cellViewModel(at indexPath: IndexPath) -> DateCellViewModel? {
        var cell = cellDict[indexPath]
        if cell == nil {
            cell = DateCellViewModelImpl()
            cellDict[indexPath] = cell
        }
        return cell
    }

    func didSelectDate(date: Date,
                       selectionType: SelectionType?,
                       indexPath: IndexPath) {
        if selectionType == .userInitiated {
            didSelectDateByUser(date: date,
                                selectionType: selectionType,
                                indexPath: indexPath)
        } else {
            didSelectDateProgramatically(date: date,
                                         selectionType: selectionType,
                                         indexPath: indexPath)

        }
    }

    func didSelectDateProgramatically(date: Date,
                                      selectionType: SelectionType?,
                                      indexPath: IndexPath) {
        // Store selectedIndexPathRange to highlight middle cells
        if date == selectedDateRange.value?.start {
            selectedIndexPathRange.accept(
                IndexPathRange(start: indexPath,
                               end: selectedIndexPathRange.value?.end)
            )
        } else if date == selectedDateRange.value?.end {
            selectedIndexPathRange.accept(
                IndexPathRange(start: selectedIndexPathRange.value?.start,
                               end: indexPath)
            )
        }
    }

    func didSelectDateByUser(date: Date,
                             selectionType: SelectionType?,
                             indexPath: IndexPath) {
        // Set selectedDateRange and selectedIndexPathRange when user select
        if let selectedStartDate = selectedDateRange.value?.start {
            if let selectedEndDate = selectedDateRange.value?.end {
                let isInRange = (selectedStartDate < date && date < selectedEndDate)
                if isInRange == false {
                    selectedDateRange.accept(DateRange(start: date, end: nil))
                    selectedIndexPathRange.accept(IndexPathRange(start: indexPath, end: nil))
                }
            } else {
                if date > selectedStartDate {
                    selectedDateRange.accept(
                        DateRange(start: selectedDateRange.value?.start,
                                  end: date)
                    )
                    selectedIndexPathRange.accept(
                        IndexPathRange(start: selectedIndexPathRange.value?.start,
                                       end: indexPath)
                    )
                } else {
                    selectedDateRange.accept(DateRange(start: date, end: nil))
                    selectedIndexPathRange.accept(IndexPathRange(start: indexPath, end: nil))
                }
            }
        } else {
            selectedDateRange.accept(DateRange(start: date, end: nil))
            selectedIndexPathRange.accept(IndexPathRange(start: indexPath, end: nil))
        }
    }

    func shouldSelectDate(_ date: Date,
                          selectionType: SelectionType?,
                          dateBelongsTo: DateOwner,
                          indexPath: IndexPath) -> Bool {
        guard dateBelongsTo == .thisMonth else { return false }
        guard selectionType == .userInitiated else { return true }
        if let selectedStartDate = selectedDateRange.value?.start {
            if let selectedEndDate = selectedDateRange.value?.end {
                // If select in an already selected date range, then do not allow it
                let isInRange = (selectedStartDate < date && date < selectedEndDate)
                return !isInRange
            } else {
                return true
            }
        } else {
            return true
        }
    }

    func shouldDeselectDate(_ date: Date,
                            selectionType: SelectionType?,
                            indexPath: IndexPath) -> Bool {
        guard selectionType != .programatic else { return true }
        if selectedDateRange.value?.end == nil {
            selectedDateRange.accept(DateRange(start: date, end: date))
            selectedIndexPathRange.accept(IndexPathRange(start: indexPath, end: indexPath))
            return false
        } else {
            if let start = selectedDateRange.value?.start, let end = selectedDateRange.value?.end {
                if (date > start && date < end) || date == start || date == end {
                    selectedDateRange.accept(DateRange(start: date, end: nil))
                    selectedIndexPathRange.accept(IndexPathRange(start: indexPath, end: nil))
                    return false
                }
            }
        }
        return true
    }

    func didDeselectDate(date: Date,
                         selectionType: SelectionType?,
                         indexPath: IndexPath) {
        guard selectionType == .userInitiated else { return }

        if selectedDateRange.value?.start != nil && selectedDateRange.value?.end != nil &&
            selectionType == .userInitiated {
            selectedDateRange.accept(nil)
            selectedIndexPathRange.accept(nil)
        }
    }

    func calculateSelectedPosition(at indexPath: IndexPath,
                                   dateBelongsTo: DateOwner,
                                   selectedPosition: SelectionRangePosition) -> SelectionRangePosition {
        let isMiddle: Bool

        // All cell betweens selectedStartIndexPath and selectedEndIndexPath will be middle
        if let selectedStartIndexPath = selectedIndexPathRange.value?.start,
           let selectedEndIndexPath = selectedIndexPathRange.value?.end {
            if selectedStartIndexPath < indexPath && indexPath < selectedEndIndexPath {
                isMiddle = true
            } else {
                isMiddle = false
            }
        } else {
            isMiddle = false
        }

        if isMiddle == true {
            return .middle
        } else {
            /*
             If selectedPosition not middle but the date
             does not belong to this month then do not display selectedPostition as none
             */
            if dateBelongsTo != .thisMonth {
                return .none
            } else {
                return selectedPosition
            }
        }
    }
}
