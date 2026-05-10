import SwiftUI

struct VideoPlaybackSettingsView: View {
    @AppStorage("autoplay") var autoplay: Bool = true
    @AppStorage("muteOnPlay") var muteOnPlay: Bool = false
    
    var body: some View {
        Section("Playback Settings") {
            Toggle(isOn: $autoplay) {
                Label("Autoplay Videos", systemImage: "play.fill")
            }
            Toggle(isOn: $muteOnPlay) {
                Label("Mute on Play", systemImage: "speaker.slash.fill")
            }
        }
    }
}
