import Foundation

// ============================================================
// MARK: - Игрок
// ============================================================

final class Player: GameEntity {
    let name: String
    private(set) var position: Int = 0

    init(name: String) {
        self.name = name
    }

    // Переместить игрока на новую позицию.
    func move(to newPosition: Int) {
        position = newPosition
    }
}
