//
//  ViewModel.swift
//  test
//
//  Created by Hien Pham on 2/5/22.
//  Copyright © 2022 AppleInc. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import JTAppleCalendar

struct DateRange {
    var start: Date?
    var end: Date?
}

protocol ViewModel: AnyObject {
    var selectedDateRange: BehaviorRelay<DateRange?> { get }

    func cellViewModel(at indexPath: IndexPath) -> DateCellViewModel?
    func calculateSelectedPosition(at indexPath: IndexPath,
                                   dateBelongsTo: DateOwner,
                                   selectedPosition: SelectionRangePosition) -> SelectionRangePosition
    func shouldSelectDate(_ date: Date,
                          selectionType: SelectionType?,
                          dateBelongsTo: DateOwner,
                          indexPath: IndexPath) -> Bool
    func shouldDeselectDate(_ date: Date,
                            selectionType: SelectionType?,
                            indexPath: IndexPath) -> Bool
    func didSelectDate(date: Date,
                       selectionType: SelectionType?,
                       indexPath: IndexPath)
    func didDeselectDate(date: Date,
                         selectionType: SelectionType?,
                         indexPath: IndexPath)
}
