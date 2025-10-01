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

public enum GameMode {
    case normal
    case skillSelect
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
    @Published public var blackSkillCount: Int
    @Published public var whiteSkillCount: Int
    @Published public var skillEffectPosition: (row: Int, col: Int)?
    @Published public var showSkillEffect: Bool = false
    
    public init() {
        self.board = Array(repeating: Array(repeating: nil, count: Self.boardSize), count: Self.boardSize)
        self.currentPlayer = .black
        self.gameState = .playing
        self.gameMode = .normal
        self.blackSkillCount = 2
        self.whiteSkillCount = 2
        self.skillEffectPosition = nil
        self.showSkillEffect = false
    }
    
    public func makeMove(row: Int, col: Int) -> Bool {
        guard case .playing = gameState,
              gameMode == .normal,
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
            currentPlayer = currentPlayer == .black ? .white : .black
        }
        
        return true
    }
    
    public func activateSkill() {
        guard case .playing = gameState,
              gameMode == .normal,
              canUseSkill() else {
            return
        }
        
        gameMode = .skillSelect
    }
    
    public func useSkill(row: Int, col: Int) -> Bool {
        guard case .playing = gameState,
              gameMode == .skillSelect,
              row >= 0, row < Self.boardSize,
              col >= 0, col < Self.boardSize else {
            return false
        }
        
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
        
        // 延迟结束特效和切换玩家
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showSkillEffect = false
            self.skillEffectPosition = nil
            
            if self.currentPlayer == .black {
                self.blackSkillCount -= 1
            } else {
                self.whiteSkillCount -= 1
            }
            
            self.gameMode = .normal
            self.currentPlayer = self.currentPlayer == .black ? .white : .black
        }
        
        return true
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
    
    public func resetGame() {
        board = Array(repeating: Array(repeating: nil, count: Self.boardSize), count: Self.boardSize)
        currentPlayer = .black
        gameState = .playing
        gameMode = .normal
        blackSkillCount = 2
        whiteSkillCount = 2
        skillEffectPosition = nil
        showSkillEffect = false
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