//
//  CubesPromoView.swift
//  Picpuzzie
//
//  Promotional view for Picpuzzie Cubes
//

import SwiftUI

struct CubesPromoView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.2),
                    Color.black
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Close button at top
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 20)
                }
                
                Spacer()
                
                // App icon
                Image("CubesAppIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 33))
                    .overlay(
                        RoundedRectangle(cornerRadius: 33)
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    )
                    .shadow(color: .white.opacity(0.3), radius: 20)
                
                // Title
                VStack(spacing: 10) {
                    Text("✨ NEW ✨")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.yellow)
                    
                    Text("Picpuzzie Cubes")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Experience Puzzles in 3D!")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 30)
                
                // Features
                VStack(alignment: .leading, spacing: 15) {
                    FeatureRow(icon: "cube.fill", text: "12 unique 3D puzzle types")
                    FeatureRow(icon: "photo.fill", text: "Use your own photos")
                    FeatureRow(icon: "hand.tap.fill", text: "Intuitive touch controls")
                    FeatureRow(icon: "sparkles", text: "Stunning celebrations")
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Download button
                Button {
                    // TODO: Replace with actual App Store URL when available
                    if let url = URL(string: "https://apps.apple.com/us/app/picpuzzie-cubes/id6758316548") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 24))
                        Text("Download Now")
                            .font(.system(size: 22, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.2, green: 0.5, blue: 1.0),
                                Color(red: 0.4, green: 0.2, blue: 0.9)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(15)
                    .shadow(color: Color(red: 0.3, green: 0.3, blue: 1.0).opacity(0.5), radius: 15)
                }
                .padding(.horizontal, 40)
                
                // Price
                Text("$1.99")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                
                Spacer()
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(.cyan)
                .frame(width: 30)
            
            Text(text)
                .font(.system(size: 18))
                .foregroundColor(.white)
            
            Spacer()
        }
    }
}

#Preview {
    CubesPromoView()
}
