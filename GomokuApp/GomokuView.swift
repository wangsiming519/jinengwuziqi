import SwiftUI

public struct GomokuView: View {
    @StateObject private var game = GomokuGame()
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 20) {
            Text("技能五子棋")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            gameStatusView
            
            skillStatusView
            
            GameBoardView(game: game)
            
            skillControlsView
            
            Button("重新开始") {
                game.resetGame()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    @ViewBuilder
    private var gameStatusView: some View {
        switch game.gameState {
        case .playing:
            if game.gameMode == .skillSelect {
                Text("选择对方棋子使用飞沙走石")
                    .font(.title2)
                    .foregroundColor(.red)
            } else {
                Text("当前玩家: \(game.currentPlayer.symbol)")
                    .font(.title2)
            }
        case .won(let player):
            Text("\(player.symbol) 获胜!")
                .font(.title2)
                .foregroundColor(.green)
        case .draw:
            Text("平局!")
                .font(.title2)
                .foregroundColor(.orange)
        }
    }
    
    @ViewBuilder
    private var skillStatusView: some View {
        HStack(spacing: 30) {
            VStack {
                Text("● 黑方")
                    .font(.headline)
                Text("飞沙走石: \(game.blackSkillCount)")
                    .font(.subheadline)
                    .foregroundColor(game.blackSkillCount > 0 ? .primary : .gray)
            }
            
            VStack {
                Text("○ 白方")
                    .font(.headline)
                Text("飞沙走石: \(game.whiteSkillCount)")
                    .font(.subheadline)
                    .foregroundColor(game.whiteSkillCount > 0 ? .primary : .gray)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    @ViewBuilder
    private var skillControlsView: some View {
        if case .playing = game.gameState {
            HStack(spacing: 20) {
                if game.gameMode == .normal {
                    Button("使用飞沙走石") {
                        game.activateSkill()
                    }
                    .disabled(!game.canUseSkill())
                    .buttonStyle(.bordered)
                } else {
                    Button("取消技能") {
                        game.cancelSkill()
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                }
            }
        }
    }
}

struct GameBoardView: View {
    @ObservedObject var game: GomokuGame
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<GomokuGame.boardSize, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<GomokuGame.boardSize, id: \.self) { col in
                        CellView(
                            player: game.board[row][col],
                            row: row,
                            col: col,
                            gameMode: game.gameMode
                        ) {
                            if game.gameMode == .normal {
                                game.makeMove(row: row, col: col)
                            } else {
                                game.useSkill(row: row, col: col)
                            }
                        }
                    }
                }
            }
        }
        .background(Color.brown.opacity(0.3))
        .border(Color.black, width: 2)
    }
}

struct CellView: View {
    let player: Player?
    let row: Int
    let col: Int
    let gameMode: GameMode
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            Rectangle()
                .stroke(Color.black, lineWidth: 1)
                .frame(width: 24, height: 24)
                .background(backgroundColor)
            
            if let player = player {
                Text(player.symbol)
                    .font(.system(size: 18))
                    .foregroundColor(player == .black ? .black : .white)
            }
        }
        .onTapGesture {
            onTap()
        }
    }
    
    private var backgroundColor: Color {
        if gameMode == .skillSelect && player != nil {
            return Color.red.opacity(0.3)
        } else {
            return Color.brown.opacity(0.1)
        }
    }
}

#Preview {
    GomokuView()
}