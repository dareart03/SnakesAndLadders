import Foundation

// ============================================================
// MARK: - Кубик
// ============================================================

final class Dice: DiceRolling, GameEntity {
    let name = "Dice"
    private let sides: Int

    init(sides: Int = 6) {
        self.sides = sides
    }

    // Бросок: случайное число от 1 до количества граней.
    func roll() -> Int {
        Int.random(in: 1...sides)
    }
}

// ============================================================
// MARK: - Лестница
// ============================================================

final class Ladder: BoardElement {
    let name = "Ladder"
    let position: Int
    let top: Int

    init(from: Int, to: Int) {
        self.position = from
        self.top = to
    }

    // Если игрок встал на эту клетку — поднимаем его наверх.
    func applyEffect(on position: Int) -> CellEffect {
        guard position == self.position else { return .none }
        return .move(to: top, description: "ladder")
    }
}

// ============================================================
// MARK: - Змея
// ============================================================

final class Snake: BoardElement {
    let name = "Snake"
    let position: Int
    let tail: Int

    init(head: Int, tail: Int) {
        self.position = head
        self.tail = tail
    }

    // Если игрок встал на эту клетку — спускаем его в хвост змеи.
    func applyEffect(on position: Int) -> CellEffect {
        guard position == self.position else { return .none }
        return .move(to: tail, description: "snake")
    }
}

// ============================================================
// MARK: - Доска
// ============================================================

final class Board: GameEntity {
    let name = "Board"
    let size: Int
    private(set) var elements: [BoardElement] = []

    init(size: Int = 100) {
        self.size = size
    }

    // Добавить змею или лестницу на доску.
    func add(_ element: BoardElement) {
        elements.append(element)
    }

    /// Проверяет, срабатывает ли на этой клетке какая-нибудь змея или лестница.
    func resolve(position: Int) -> CellEffect {
        for element in elements {
            let effect = element.applyEffect(on: position)
            if case .move = effect { return effect }
        }
        return .none
    }

    /// Вычисляет целевую позицию с учётом правила «ровно на последнюю клетку».
    /// Если ход уводит за пределы доски — возвращает nil (ход «сгорает»).
    func targetPosition(from current: Int, roll: Int) -> Int? {
        let candidate = current + roll
        if candidate > size {
            return nil
        }
        return candidate
    }

    /// Условие победы: игрок стоит РОВНО на последней клетке.
    func isWinning(position: Int) -> Bool {
        position == size
    }
}
