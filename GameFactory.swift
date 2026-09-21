import Foundation

// ============================================================
// MARK: - Фабрика игр
// ============================================================

/// Собирает игру с настройками по умолчанию.
/// Используется и в одиночной партии, и в турнире.
enum GameFactory {

    static let defaultPlayerNames = ["Дарья", "Дмитрий", "Артем", "Владислав"]
    static let boardSize = 100

    static func makeGame(players names: [String] = defaultPlayerNames) -> Game {
        let board = Board(size: boardSize)

        // Лестницы (откуда → куда)
        board.add(Ladder(from: 3,  to: 22))
        board.add(Ladder(from: 8,  to: 26))
        board.add(Ladder(from: 20, to: 41))
        board.add(Ladder(from: 28, to: 55))
        board.add(Ladder(from: 50, to: 91))

        // Змеи (голова → хвост)
        board.add(Snake(head: 17, tail: 4))
        board.add(Snake(head: 54, tail: 33))
        board.add(Snake(head: 62, tail: 18))
        board.add(Snake(head: 87, tail: 24))
        board.add(Snake(head: 93, tail: 73))

        let dice = Dice(sides: 6)
        let players = names.map { Player(name: $0) }
        return Game(board: board, dice: dice, players: players)
    }
}
