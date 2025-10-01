import Foundation
import AVFoundation

public enum Player: CaseIterable {
    case black
    case white
    
    var symbol: String {
        switch self {
        case .black: return "●"
        case .white: return "○"
        }
    }
}

public enum SkillType {
    case feiShaZouShi  // 飞沙走石 - 移除对方棋子 + 额外回合
    case jingRuZhiShui // 静如止水 - 额外回合
}

public enum GameMode {
    case normal
    case skillSelect(SkillType)
}

public enum GameState {
    case playing
    case won(Player)
    case draw
}

public class GomokuGame: ObservableObject {
    public static let boardSize = 15
    
    @Published public var board: [[Player?]]
    @Published public var currentPlayer: Player
    @Published public var gameState: GameState
    @Published public var gameMode: GameMode
    @Published public var blackSkillCount: Int  // 黑方技能次数
    @Published public var whiteSkillCount: Int  // 白方技能次数
    @Published public var skillEffectPosition: (row: Int, col: Int)?
    @Published public var showSkillEffect: Bool = false
    @Published public var hasExtraTurn: Bool = false  // 是否有额外回合
    
    public init() {
        self.board = Array(repeating: Array(repeating: nil, count: Self.boardSize), count: Self.boardSize)
        self.currentPlayer = .black
        self.gameState = .playing
        self.gameMode = .normal
        self.blackSkillCount = 2  // 每位玩家2次技能使用机会
        self.whiteSkillCount = 2  // 每位玩家2次技能使用机会
        self.skillEffectPosition = nil
        self.showSkillEffect = false
        self.hasExtraTurn = false
    }
    
    public func makeMove(row: Int, col: Int) -> Bool {
        guard case .playing = gameState,
              case .normal = gameMode,
              row >= 0, row < Self.boardSize,
              col >= 0, col < Self.boardSize,
              board[row][col] == nil else {
            return false
        }
        
        board[row][col] = currentPlayer
        playPieceSound()
        
        if checkWin(row: row, col: col, player: currentPlayer) {
            gameState = .won(currentPlayer)
            playWinSound()
        } else if isBoardFull() {
            gameState = .draw
        } else {
            // 检查是否有额外回合
            if hasExtraTurn {
                hasExtraTurn = false  // 消耗额外回合
                // 不切换玩家，继续当前玩家下棋
            } else {
                currentPlayer = currentPlayer == .black ? .white : .black
            }
        }
        
        return true
    }
    
    public func activateSkill(_ skillType: SkillType) {
        guard case .playing = gameState,
              case .normal = gameMode,
              canUseSkill() else {
            return
        }
        
        if skillType == .jingRuZhiShui {
            // 静如止水：直接获得额外回合
            hasExtraTurn = true
            useSkillPoint()
            playButtonSound()
        } else {
            // 飞沙走石：进入选择模式
            gameMode = .skillSelect(skillType)
        }
    }
    
    public func useSkill(row: Int, col: Int) -> Bool {
        guard case .playing = gameState,
              case .skillSelect(let skillType) = gameMode,
              row >= 0, row < Self.boardSize,
              col >= 0, col < Self.boardSize else {
            return false
        }
        
        if skillType == .feiShaZouShi {
            let opponentPlayer = currentPlayer == .black ? Player.white : Player.black
            
            guard board[row][col] == opponentPlayer else {
                return false
            }
            
            // 触发特效和音效
            skillEffectPosition = (row: row, col: col)
            showSkillEffect = true
            playSkillSound()
            
            // 延迟移除棋子以显示特效
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.board[row][col] = nil
            }
            
            // 延迟结束特效并给予额外回合
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.showSkillEffect = false
                self.skillEffectPosition = nil
                
                self.useSkillPoint()
                self.gameMode = .normal
                
                // 飞沙走石：移除棋子后获得额外回合
                self.hasExtraTurn = true
                // 不切换玩家，让当前玩家继续下棋
            }
            
            return true
        }
        
        return false
    }
    
    public func cancelSkill() {
        gameMode = .normal
    }
    
    public func canUseSkill() -> Bool {
        return currentPlayer == .black ? blackSkillCount > 0 : whiteSkillCount > 0
    }
    
    public func getCurrentPlayerSkillCount() -> Int {
        return currentPlayer == .black ? blackSkillCount : whiteSkillCount
    }
    
    // 通用技能使用方法，为未来多技能扩展做准备
    public func useSkillPoint() {
        if currentPlayer == .black {
            blackSkillCount = max(0, blackSkillCount - 1)
        } else {
            whiteSkillCount = max(0, whiteSkillCount - 1)
        }
    }
    
    public func resetGame() {
        board = Array(repeating: Array(repeating: nil, count: Self.boardSize), count: Self.boardSize)
        currentPlayer = .black
        gameState = .playing
        gameMode = .normal
        blackSkillCount = 2  // 重置技能次数
        whiteSkillCount = 2  // 重置技能次数
        skillEffectPosition = nil
        showSkillEffect = false
        hasExtraTurn = false
    }
    
    private func checkWin(row: Int, col: Int, player: Player) -> Bool {
        let directions = [
            (0, 1),   // horizontal
            (1, 0),   // vertical
            (1, 1),   // diagonal \
            (1, -1)   // diagonal /
        ]
        
        for (dr, dc) in directions {
            var count = 1
            
            // Check in positive direction
            var r = row + dr
            var c = col + dc
            while r >= 0 && r < Self.boardSize && c >= 0 && c < Self.boardSize && board[r][c] == player {
                count += 1
                r += dr
                c += dc
            }
            
            // Check in negative direction
            r = row - dr
            c = col - dc
            while r >= 0 && r < Self.boardSize && c >= 0 && c < Self.boardSize && board[r][c] == player {
                count += 1
                r -= dr
                c -= dc
            }
            
            if count >= 5 {
                return true
            }
        }
        
        return false
    }
    
    private func isBoardFull() -> Bool {
        for row in board {
            for cell in row {
                if cell == nil {
                    return false
                }
            }
        }
        return true
    }
    
    private func playSkillSound() {
        AudioServicesPlaySystemSound(SystemSoundID(1016)) // 爆炸音
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            AudioServicesPlaySystemSound(SystemSoundID(1000)) // 点击音
        }
    }
    
    private func playPieceSound() {
        AudioServicesPlaySystemSound(SystemSoundID(1123)) // 轻柔的点击音
    }
    
    private func playWinSound() {
        AudioServicesPlaySystemSound(SystemSoundID(1025)) // 成功音
    }
    
    private func playButtonSound() {
        AudioServicesPlaySystemSound(SystemSoundID(1104)) // 按钮音
    }
}