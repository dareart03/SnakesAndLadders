import Foundation

// ============================================================
// MARK: - Логгер (Observer)
// ============================================================

/// Печатает события игры в консоль на русском языке.
final class GameLogger: GameEventObserver {
    func receive(event: GameEvent) {
        switch event {
        case .gameStarted(let title):
            print("=== Началась новая игра: \(title) ===")

        case .cycleStarted(let number):
            print("======")
            print("Цикл \(number):")

        case .turnStarted(let player):
            // Отступ перед фразой о броске
            print("   \(player) бросает кубик")

        case .diceRolled(_, let value):
            print("Выпало число: \(value)")

        case .playerMoved(let player, let from, let to):
            print("\(player) перемещается с клетки \(from) на клетку \(to)")

        case .playerStayed(let player, let position, let reason):
            print("\(player) остаётся на клетке \(position): \(reason)")

        case .playerClimbedLadder(let player, _, let to):
            print("\(player) поднимается по лестнице на клетку \(to)")

        case .playerBittenBySnake(let player, _, let to):
            print("\(player) укушен змеёй и спускается на клетку \(to)")

        case .playerWon(let player):
            print("======")
            print("🏆 \(player) побеждает в игре!")
        }
    }
}

// ============================================================
// MARK: - Игра (FSM + Delegate + Observer)
// ============================================================

final class Game: GameDelegate {
    let title = "Змеи и Лестницы"
    private let dice: Dice
    private let board: Board
    private let players: [Player]
    private var currentIndex: Int = 0
    private var cycleNumber: Int = 0
    private var observers: [GameEventObserver] = []
    private var state: GameState = .idle

    init(board: Board, dice: Dice, players: [Player]) {
        self.board = board
        self.dice = dice
        self.players = players
    }

    // Подписать наблюдателя на события игры.
    func addObserver(_ observer: GameEventObserver) {
        observers.append(observer)
    }

    // Разослать событие всем наблюдателям.
    private func emit(_ event: GameEvent) {
        observers.forEach { $0.receive(event: event) }
    }

    // Сменить состояние FSM и уведомить делегата.
    private func transition(to newState: GameState) {
        state = newState
        gameDidChangeState(newState)
    }

    // Точка входа: запустить игру.
    func start() {
        transition(to: .setup)
        emit(.gameStarted(title: title))
        transition(to: .awaitingRoll(playerIndex: 0))
        mainLoop()
    }

    /// Основной цикл: идём по игрокам по кругу, пока кто-то не победит.
    /// Один полный круг по всем игрокам = один цикл.
    private func mainLoop() {
        while true {
            // Начинаем новый цикл, когда очередь снова у первого игрока
            if currentIndex == 0 {
                cycleNumber += 1
                emit(.cycleStarted(number: cycleNumber))
            }

            let player = players[currentIndex]
            let ended = playTurn(for: player)
            if ended { return }

            currentIndex = (currentIndex + 1) % players.count
            transition(to: .awaitingRoll(playerIndex: currentIndex))
        }
    }

    /// Ход одного игрока. Возвращает true, если игра закончилась.
    private func playTurn(for player: Player) -> Bool {
        playerDidStartTurn(player)
        emit(.turnStarted(player: player.name))

        // 1. Бросок кубика
        transition(to: .rollingDice(playerIndex: currentIndex))
        let roll = dice.roll()
        emit(.diceRolled(player: player.name, value: roll))

        // 2. Проверяем, можно ли сходить по правилу «ровно 100»
        let from = player.position
        guard let target = board.targetPosition(from: from, roll: roll) else {
            emit(.playerStayed(player: player.name,
                               position: from,
                               reason: "перебор — нужно ровно \(board.size)"))
            return false
        }

        // 3. Перемещение
        transition(to: .moving(playerIndex: currentIndex, from: from, to: target))
        player.move(to: target)
        emit(.playerMoved(player: player.name, from: from, to: target))

        // 4. Разбор клетки (змея или лестница)
        transition(to: .resolvingCell(playerIndex: currentIndex))
        if case .move(let newPos, let description) = board.resolve(position: target) {
            player.move(to: newPos)
            if description == "ladder" {
                emit(.playerClimbedLadder(player: player.name, from: target, to: newPos))
            } else {
                emit(.playerBittenBySnake(player: player.name, from: target, to: newPos))
            }
        }

        // 5. Проверка победы (ровно 100)
        transition(to: .checkingWin(playerIndex: currentIndex))
        if board.isWinning(position: player.position) {
            transition(to: .gameOver(winner: player.name))
            emit(.playerWon(player: player.name))
            gameDidEnd(winner: player)
            return true
        }

        return false
    }

    // MARK: - GameDelegate
    func gameDidChangeState(_ state: GameState) { }
    func playerDidStartTurn(_ player: Player) { }
    func gameDidEnd(winner: Player) { }
}
