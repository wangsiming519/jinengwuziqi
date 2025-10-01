import SwiftUI

public struct GomokuView: View {
    @StateObject private var game = GomokuGame()
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 20) {
            Text("机能五子棋")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            gameStatusView
            
            GameBoardView(game: game)
            
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
            Text("当前玩家: \(game.currentPlayer.symbol)")
                .font(.title2)
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
                            col: col
                        ) {
                            game.makeMove(row: row, col: col)
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
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            Rectangle()
                .stroke(Color.black, lineWidth: 1)
                .frame(width: 24, height: 24)
                .background(Color.brown.opacity(0.1))
            
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
}

#Preview {
    GomokuView()
}