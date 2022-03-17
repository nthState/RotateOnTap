//
//  SwiftUIView.swift
//  
//
//  Created by Chris Davis on 17/03/2022.
//

import SwiftUI

struct ExampleView { }

extension ExampleView: View {
  
  var body: some View {
    VStack {
      Rectangle()
        .fill(Color.yellow)
        .frame(width: 120, height: 80, alignment: .center)
        .rotateOnTap(angle: Angle.degrees(5))
    }
  }
  
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ExampleView()
  }
}
