import Foundation

// ============================================================
// MARK: - События (паттерн Observer)
// ============================================================

/// Все события, которые могут произойти в игре.
/// Наблюдатели подписываются на них, чтобы реагировать
/// (писать лог, обновлять UI и т.д.).
enum GameEvent {
    case gameStarted(title: String)
    case cycleStarted(number: Int)
    case turnStarted(player: String)
    case diceRolled(player: String, value: Int)
    case playerMoved(player: String, from: Int, to: Int)
    case playerStayed(player: String, position: Int, reason: String)
    case playerClimbedLadder(player: String, from: Int, to: Int)
    case playerBittenBySnake(player: String, from: Int, to: Int)
    case playerWon(player: String)
}

// ============================================================
// MARK: - Состояния игры (FSM — конечный автомат)
// ============================================================

/// Конечный автомат игры.
/// Каждый ход проходит через эти состояния по порядку.
enum GameState {
    case idle
    case setup
    case awaitingRoll(playerIndex: Int)
    case rollingDice(playerIndex: Int)
    case moving(playerIndex: Int, from: Int, to: Int)
    case resolvingCell(playerIndex: Int)
    case checkingWin(playerIndex: Int)
    case gameOver(winner: String)
}

// ============================================================
// MARK: - Протоколы
// ============================================================

/// Любой объект игры, у которого есть имя.
protocol GameEntity: AnyObject {
    var name: String { get }
}

/// Всё, что можно бросить как кубик.
protocol DiceRolling {
    func roll() -> Int
}

/// Результат попадания на клетку доски.
enum CellEffect {
    case move(to: Int, description: String)
    case none
}

/// Клетка доски со своим поведением (змея, лестница и т.п.).
protocol BoardElement: GameEntity {
    var position: Int { get }
    func applyEffect(on position: Int) -> CellEffect
}

/// Наблюдатель за событиями игры.
protocol GameEventObserver: AnyObject {
    func receive(event: GameEvent)
}

/// Делегат, получающий уведомления о смене состояний FSM и ключевых моментах.
protocol GameDelegate: AnyObject {
    func gameDidChangeState(_ state: GameState)
    func playerDidStartTurn(_ player: Player)
    func gameDidEnd(winner: Player)
}
