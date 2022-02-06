//
//  DateCellViewModel.swift
//  test
//
//  Created by Hien Pham on 2/5/22.
//  Copyright © 2022 AppleInc. All rights reserved.
//

import Foundation
import RxCocoa
import JTAppleCalendar

protocol DateCellViewModel: AnyObject {
    var dateText: BehaviorRelay<String?> { get }
    var day: BehaviorRelay<DaysOfWeek?> { get }
    var isSelected: BehaviorRelay<Bool> { get }
    var selectedPosition: BehaviorRelay<SelectionRangePosition> { get }
    var dateBelongsTo: BehaviorRelay<DateOwner?> { get }
}
