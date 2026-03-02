
import SwiftUI
struct PhoneMockup: View {
    let imageName: String
    let caption: String

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.black)
                    .frame(width: 160, height: 320)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )

                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 310)
                    .clipShape(RoundedRectangle(cornerRadius: 26))
            }

            Text(caption)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
    }
}
//
//  PhoneMockup.swift
//  Taro AI
//
//  Created by Vitaly on 13.12.2025.
//

