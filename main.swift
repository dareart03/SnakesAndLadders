import Foundation

// ============================================================
// MARK: - Настройка и запуск игры
// ============================================================

let board = Board(size: 100)

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

// Кубик на 6 граней
let dice = Dice(sides: 6)

// Четыре игрока
let players: [Player] = [
    Player(name: "Дарья"),
    Player(name: "Дмитрий"),
    Player(name: "Артем"),
    Player(name: "Владислав")
]

// Создаём игру
let game = Game(board: board, dice: dice, players: players)

// Подключаем логгер как наблюдателя
let logger = GameLogger()
game.addObserver(logger)

// Запуск!
game.start()
