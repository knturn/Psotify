//
//  SectionGridViewUIModel.swift
//  Psotify
//
//  Created by Turan, Kaan on 29.11.2024.
//

import Foundation

struct SectionGridViewUIModel {
  let title: String
  let gridItems: [AlbumItem]?

  init(title: String, gridItems: [AlbumItem]?) {
    self.title = title
    self.gridItems = gridItems
  }
}
