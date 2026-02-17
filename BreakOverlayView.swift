import SwiftUI
#if os(macOS)
import AppKit
#endif

// this view is for macOS full screen break overlay
// on iOS we use BreakView, this is more macOS focused
struct BreakOverlayView: View {
    @ObservedObject var manager: FocusModeTimer
    
    var body: some View {
        ZStack {
            // black background - full screen
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            // content
            VStack(spacing: 40) {
                Text("BREAK TIME")
                    .font(.system(size: 60, weight: .heavy))
                    .foregroundColor(.white)
                    .tracking(5)
                
                LottieView()
                    .frame(width: 350, height: 350)
                
                VStack(spacing: 10) {
                    Text("Screen unlocks in")
                        .font(.title2)
                        .foregroundColor(.gray)
                    
                    Text("\(Int(manager.timeRemaining))")
                        .font(.system(size: 80, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                        .contentTransition(.numericText())
                    
                    Text("seconds")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
        }
#if os(macOS)
        .onAppear {
            NSApp.presentationOptions = [.hideDock, .hideMenuBar, .disableProcessSwitching]
        }
#endif
#if os(macOS)
        .onDisappear {
            NSApp.presentationOptions = []
        }
#endif
    }
}

