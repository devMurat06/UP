import Foundation
import Combine
import AVFoundation
import AudioToolbox
import UIKit

// ========================================
// AMBIENT SOUND OPTIONS
// ========================================

// the sounds user can pick for focus mode
// I wanted to add more but these are the main ones people use
enum AmbientSound: String, CaseIterable {
    case none = "Off"
    case rain = "Rain"
    case forest = "Forest"
    case whiteNoise = "White Noise"
    case cafe = "Cafe"
    
    // SF Symbol icon for each sound
    var icon: String {
        switch self {
        case .none: return "speaker.slash"
        case .rain: return "cloud.rain"
        case .forest: return "leaf"
        case .whiteNoise: return "waveform"
        case .cafe: return "cup.and.saucer"
        }
    }
    
    // system sound ID (iOS built-in sounds)
    // in a real app you'd use mp3/wav files here
    var systemSoundID: SystemSoundID {
        switch self {
        case .none: return 0
        case .rain: return 1104    // placeholder sound
        case .forest: return 1105  // placeholder sound
        case .whiteNoise: return 1106
        case .cafe: return 1107
        }
    }
}

// ========================================
// SOUND MANAGER (Singleton)
// ========================================

// singleton pattern so there's only one instance across the app
class SoundManager: ObservableObject {
    
    // single instance
    static let shared = SoundManager()
    
    // currently selected sound
    @Published var selectedSound: AmbientSound = .none
    
    // is sound playing?
    @Published var isPlaying: Bool = false
    
    // is Do Not Disturb enabled by us?
    @Published var silentModeActive: Bool = false
    
    // timer for looping (in real app you'd use AVAudioPlayer)
    private var loopTimer: Timer?
    
    // private init - can't create new instances from outside
    private init() {}
    
    // ========================================
    // PUBLIC METHODS
    // ========================================
    
    func selectSound(_ sound: AmbientSound) {
        // if same sound selected again, turn it off
        if selectedSound == sound && sound != .none {
            stopSound()
            disableSilentMode()
            selectedSound = .none
            return
        }
        
        // select new sound
        selectedSound = sound
        
        if sound != .none {
            playSound()
            enableSilentMode()  // auto-enable silent mode when focus sound is on
        } else {
            stopSound()
            disableSilentMode()
        }
    }
    
    func playSound() {
        guard selectedSound != .none else { return }
        
        isPlaying = true
        
        // haptic feedback - feel that sound started
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        // note: in a real app you'd use AVAudioPlayer with loop
        // using system sound as placeholder here
        AudioServicesPlaySystemSound(selectedSound.systemSoundID)
    }
    
    func stopSound() {
        isPlaying = false
        loopTimer?.invalidate()
        loopTimer = nil
    }
    
    // ========================================
    // SILENT MODE / DO NOT DISTURB
    // ========================================
    
    // enable silent mode when focus sound starts
    // this uses AVAudioSession to reduce interruptions
    private func enableSilentMode() {
        do {
            // set audio session to reduce interruptions
            // this helps user focus by dimming other sounds
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.duckOthers]  // duck (lower volume of) other audio
            )
            try AVAudioSession.sharedInstance().setActive(true)
            silentModeActive = true
            
            // note: full Do Not Disturb requires user to enable Focus mode manually
            // apps can't fully control DND due to iOS restrictions
            // but we can guide user with a notification
            print("Silent mode enabled - other audio will be ducked")
            
        } catch {
            // if it fails, just continue without it
            // not critical for the app to work
            print("Couldn't enable silent mode: \(error)")
        }
    }
    
    private func disableSilentMode() {
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            silentModeActive = false
            print("Silent mode disabled")
        } catch {
            print("Couldn't disable silent mode: \(error)")
        }
    }
    
    // called when app goes to background
    func pauseForBackground() {
        stopSound()
    }
    
    // called when app comes back to foreground
    func resumeFromBackground() {
        if selectedSound != .none {
            playSound()
        }
    }
}
