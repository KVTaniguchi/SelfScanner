//
//  VisionErrors.swift
//  Shelf Scanner
//
//  Created by Kevin Taniguchi on 1/18/20.
//  Copyright © 2020 Kevin Taniguchi. All rights reserved.
//

import Foundation

enum VisionTrackerProcessorError: Error {
    case readerInitializationFailed
    case firstFrameReadFailed
    case objectTrackingFailed
    case rectangleDetectionFailed
}
