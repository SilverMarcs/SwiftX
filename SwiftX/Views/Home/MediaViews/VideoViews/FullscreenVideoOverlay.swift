import SwiftUI
import AVKit

struct FullscreenVideoOverlay: View {
    @Environment(\.videoNS) private var videoNS
    @Namespace private var fallbackNS
    var viewModel: VideoOverlayViewModel = .shared
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false
    
    var body: some View {
        if viewModel.isPresented, let player = viewModel.player {
            ZStack {
                Color.black.ignoresSafeArea()
                VideoPlayer(player: player)
                    .matchedGeometryEffect(id: viewModel.currentVideoURL ?? "videoPlayer", in: videoNS ?? fallbackNS)
                    .offset(dragOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                isDragging = true
                                if value.translation.height > 0 {
                                    dragOffset = value.translation
                                }
                            }
                            .onEnded { value in
                                isDragging = false
                                if value.translation.height > 70 {
                                    dismissVideo()
                                } else {
                                    withAnimation(.easeInOut(duration: 0.4)) {
                                        dragOffset = .zero
                                    }
                                }
                            }
                    )
            }
            .onChange(of: viewModel.isPresented) { oldValue, newValue in
                if !newValue {
                    dragOffset = .zero
                }
            }
            #if os(macOS)
            .toolbarVisibility(.hidden, for: .windowToolbar)
            .overlay(alignment: .topLeading) {
                Button(role: .close) {
                    dismissVideo()
                }
                .keyboardShortcut(.cancelAction)
                .controlSize(.extraLarge)
                .labelStyle(.iconOnly)
                .padding(20)
            }
            #endif
        }
    }
    
    private func dismissVideo() {
        withAnimation(.easeInOut(duration: 0.4)) {
            dragOffset = .zero
            viewModel.dismiss()
        }
    }
}
