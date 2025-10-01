import SwiftUI
import AVFoundation

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
            if case .skillSelect(let skillType) = game.gameMode {
                if skillType == .feiShaZouShi {
                    Text("选择对方棋子使用飞沙走石")
                        .font(.title2)
                        .foregroundColor(.red)
                } else {
                    Text("技能已激活")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            } else {
                VStack {
                    Text("当前玩家: \(game.currentPlayer.symbol)")
                        .font(.title2)
                    if game.hasExtraTurn {
                        Text("技能效果 - 额外回合")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
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
                Text("技能数: \(game.blackSkillCount)")
                    .font(.subheadline)
                    .foregroundColor(game.blackSkillCount > 0 ? .primary : .gray)
            }
            
            VStack {
                Text("○ 白方")
                    .font(.headline)
                Text("技能数: \(game.whiteSkillCount)")
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
            if case .normal = game.gameMode {
                VStack(spacing: 10) {
                    HStack(spacing: 15) {
                        Button("飞沙走石") {
                            AudioServicesPlaySystemSound(SystemSoundID(1104)) // 按钮音
                            withAnimation(.easeInOut(duration: 0.3)) {
                                game.activateSkill(.feiShaZouShi)
                            }
                        }
                        .disabled(!game.canUseSkill())
                        .buttonStyle(.bordered)
                        
                        Button("静如止水") {
                            AudioServicesPlaySystemSound(SystemSoundID(1104)) // 按钮音
                            withAnimation(.easeInOut(duration: 0.3)) {
                                game.activateSkill(.jingRuZhiShui)
                            }
                        }
                        .disabled(!game.canUseSkill())
                        .buttonStyle(.bordered)
                    }
                    
                    Text("飞沙走石：移除对方棋子+额外回合 | 静如止水：额外回合")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
            } else {
                Button("取消技能") {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        game.cancelSkill()
                    }
                }
                .buttonStyle(.bordered)
                .foregroundColor(.red)
                .scaleEffect(1.05)
                .shadow(color: .red, radius: 3)
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
                            gameMode: game.gameMode,
                            game: game
                        ) {
                            if case .normal = game.gameMode {
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
    let game: GomokuGame
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
            
            // 技能特效
            if game.showSkillEffect,
               let effectPos = game.skillEffectPosition,
               effectPos.row == row && effectPos.col == col {
                SkillEffectView()
            }
        }
        .onTapGesture {
            onTap()
        }
    }
    
    private var backgroundColor: Color {
        if case .skillSelect(let skillType) = gameMode, skillType == .feiShaZouShi && player != nil {
            return Color.red.opacity(0.3)
        } else {
            return Color.brown.opacity(0.1)
        }
    }
}

#Preview {
    GomokuView()
}