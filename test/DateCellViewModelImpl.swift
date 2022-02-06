//
//  DateCellViewModelImpl.swift
//  test
//
//  Created by Hien Pham on 2/5/22.
//  Copyright © 2022 AppleInc. All rights reserved.
//

import Foundation
import RxCocoa
import JTAppleCalendar

class DateCellViewModelImpl: DateCellViewModel {
    let dateText: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let day: BehaviorRelay<DaysOfWeek?> = BehaviorRelay(value: nil)
    let isSelected: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let selectedPosition: BehaviorRelay<SelectionRangePosition> = BehaviorRelay(value: SelectionRangePosition.none)
    let dateBelongsTo: BehaviorRelay<DateOwner?> = BehaviorRelay(value: nil)
}
