//
//  Item.swift
//  indieee
//
//  Created by Yuki Hashizumi on 2026/03/05.
//

import Foundation
import SwiftData

@Model
final class Item {
  var timestamp: Date
  var title: String?

  init(timestamp: Date, title: String? = nil) {
    self.timestamp = timestamp
  }
}
