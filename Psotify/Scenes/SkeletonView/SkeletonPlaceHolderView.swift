//
//  SkeletonPlaceHolderView.swift
//  Psotify
//
//  Created by Turan, Kaan on 28.11.2024.
//

import SwiftUI

struct SkeletonPlaceHolderView<Content: View>: View {
    private let gridLayout: [GridItem]
    private let content: () -> Content
    private let itemHeight: CGFloat
    private let spacing: CGFloat

    private var itemCount: Int {
        let rows = Int((UIScreen.main.bounds.height / (itemHeight + spacing)))
        return rows * gridLayout.count
    }

    init(columns: Int = 2,
         itemHeight: CGFloat = 90,
         spacing: CGFloat = 10,
         @ViewBuilder content: @escaping () -> Content) {
        self.gridLayout = Array(repeating: GridItem(.flexible()), count: columns)
        self.itemHeight = itemHeight
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        LazyVGrid(columns: gridLayout, spacing: spacing) {
            ForEach(0..<itemCount, id: \.self) { _ in
                content()
                    .frame(height: itemHeight)
            }
        }
        .padding(.horizontal, spacing)
    }
}

