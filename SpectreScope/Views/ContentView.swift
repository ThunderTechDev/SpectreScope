//
//  ContentView.swift
//  SpectreScope
//
//  Created by Sergio Gonzalez Cristobal on 19/7/23.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    var body: some View {
        
        
        ZStack {
            
            Color.black
                .edgesIgnoringSafeArea(.all)
            Image("BackgroundTexture")
                           .resizable()
                           
                           .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                           .padding(.all)
                           
                        
            
            VStack {
                
                Text("SpectreScope")
                    .font(Font.custom("Chalkduster", size: 50))
                    .fontWeight(.heavy)
                    .foregroundColor(Color.white)
                    .shadow(color: .gray, radius: 2, x: 2, y: 2)
                    .padding()
                
                SpriteView(scene: SKScene(fileNamed: "Radar.sks")!, options:
                    [.allowsTransparency])
                    .frame(width: 400, height: 400) 
                    .cornerRadius(20)
                       .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.black, lineWidth: 4))
                    .cornerRadius(20)
                
                    
            }
            
            .padding()
            
            
        }
            
       
     }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPhone 11")
    }
}
