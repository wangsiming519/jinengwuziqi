import Foundation
import AVFoundation

class SoundEffectManager: ObservableObject {
    static let shared = SoundEffectManager()
    
    private init() {}
    
    func playSkillEffect() {
        // 播放飞沙走石音效
        // 这里暂时用系统音效，以后可以替换为自定义音效文件
        AudioServicesPlaySystemSound(SystemSoundID(1016)) // 短促的爆炸音
        
        // 延迟播放第二个音效
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            AudioServicesPlaySystemSound(SystemSoundID(1000)) // 点击音
        }
    }
    
    func playPiecePlace() {
        // 播放下棋音效
        AudioServicesPlaySystemSound(SystemSoundID(1123)) // 轻柔的点击音
    }
    
    func playGameWin() {
        // 播放获胜音效
        AudioServicesPlaySystemSound(SystemSoundID(1025)) // 成功音
    }
    
    func playButtonTap() {
        // 播放按钮点击音效
        AudioServicesPlaySystemSound(SystemSoundID(1104)) // 轻微点击音
    }
}