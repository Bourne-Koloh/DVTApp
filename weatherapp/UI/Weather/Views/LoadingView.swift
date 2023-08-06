//
//  LoadingView.swift
//  weatherapp
//
//  Created by Bourne Koloh on 05/08/2023.
//  Email : bournekolo@icloud.com
//

import Foundation
import SwiftUI
import UIKit

@available(iOS 13.0, *)
struct ActivityIndicator: UIViewRepresentable {

    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style
    let spinnerColor: Color
    
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: style)
        indicator.color = spinnerColor.uiColor()
        return indicator
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}


@available(iOS 13.0, *)
struct LoadingView<Content>: View where Content: View {

    let title:String?
    @Binding var isShowing: Bool
    
    
    var content: () -> Content

    var body: some View {
        GeometryReader { geometry in
            
            ZStack(alignment: .center) {

                self.content()
                    .disabled(self.isShowing)
                    .blur(radius: self.isShowing ? 3 : 0)
                    .animation(.default)
                
                withAnimation(.easeIn(duration: 1000)) {
                    VStack {
                        //
                        Text(title ?? "Please Wait ..")
                            .foregroundColor(.white)
                        //
                        ActivityIndicator(isAnimating: .constant(true), style: .large,spinnerColor: Color.white)
                        
                            .foregroundColor(Color.white)
                    }
                    //.frame(width: geometry.size.width / 2, height: geometry.size.height / 5)
                    .frame(width: min(140,140 * UIUtils.screenWidthRatio), height: min(140,140 * UIUtils.screenHeightRatio))
                        //.background(Color.colorAccent)
                        .background(Color(UIUtils.colorAccent))
                    .foregroundColor(Color.primary)
                    .cornerRadius(20)
                    .opacity(self.isShowing ? 1 : 0)
                }
                

            }
        }
    }

}

@available(iOS 13.0, *)
struct ActivityIndicator_Previews: PreviewProvider {
    static var previews: some View {
        ActivityIndicator(isAnimating: .constant(true), style: .large, spinnerColor: Color.gray)
    }
}
