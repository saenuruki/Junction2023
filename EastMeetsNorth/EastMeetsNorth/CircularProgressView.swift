//
//  CircularProgressView.swift
//  EastMeetsNorth
//
//  Created by Sae Nuruki on 2023/11/11.
//

import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    
    let accentColor: Color = .init(red: 83 / 255, green: 178 / 255, blue: 235 / 255)
    let baseColor: Color = .init(red: 59 / 255, green: 63 / 255, blue: 73 / 255)

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    baseColor,
                    lineWidth: 4
                )
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    accentColor,
                    style: StrokeStyle(
                        lineWidth: 4,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                // 1
                .animation(.easeOut, value: progress)

        }
    }
}
