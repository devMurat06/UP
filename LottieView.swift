import SwiftUI
import UIKit
import DotLottie

struct LottieView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView(frame: .zero)
        
        // Animasyon konfigürasyonu
        let animation = DotLottieAnimation(
            webURL: "https://lottie.host/104f1e87-681b-48b3-83e2-03e87ea5c804/Di7NqoGc1X.lottie",
            config: AnimationConfig(autoplay: true, loop: true)
        )
        
        // DÜZELTME BURADA: Türü açıkça belirttik (: UIView)
        let lottieView: UIView = animation.view()
        
        lottieView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(lottieView)
        
        NSLayoutConstraint.activate([
            lottieView.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            lottieView.heightAnchor.constraint(equalTo: containerView.heightAnchor),
            lottieView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            lottieView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
