import Foundation

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
    
    public init() {
        self.board = Array(repeating: Array(repeating: nil, count: Self.boardSize), count: Self.boardSize)
        self.currentPlayer = .black
        self.gameState = .playing
    }
    
    public func makeMove(row: Int, col: Int) -> Bool {
        guard case .playing = gameState,
              row >= 0, row < Self.boardSize,
              col >= 0, col < Self.boardSize,
              board[row][col] == nil else {
            return false
        }
        
        board[row][col] = currentPlayer
        
        if checkWin(row: row, col: col, player: currentPlayer) {
            gameState = .won(currentPlayer)
        } else if isBoardFull() {
            gameState = .draw
        } else {
            currentPlayer = currentPlayer == .black ? .white : .black
        }
        
        return true
    }
    
    public func resetGame() {
        board = Array(repeating: Array(repeating: nil, count: Self.boardSize), count: Self.boardSize)
        currentPlayer = .black
        gameState = .playing
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
}