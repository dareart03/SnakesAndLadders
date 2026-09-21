import Foundation

// ============================================================
// MARK: - Сборщик статистики (Observer)
// ============================================================

/// Наблюдатель, который не печатает, а копит статистику
/// по одной партии: кто победил, сколько было циклов,
/// сколько бросков, сколько сработало змей и лестниц и т.д.
final class StatsCollector: GameEventObserver {
    private(set) var winner: String?
    private(set) var cycles: Int = 0
    private(set) var rolls: Int = 0
    private(set) var laddersUsed: Int = 0
    private(set) var snakesUsed: Int = 0
    private(set) var stays: Int = 0

    func receive(event: GameEvent) {
        switch event {
        case .cycleStarted:
            cycles += 1

        case .diceRolled:
            rolls += 1

        case .playerClimbedLadder:
            laddersUsed += 1

        case .playerBittenBySnake:
            snakesUsed += 1

        case .playerStayed:
            stays += 1

        case .playerWon(let player):
            winner = player

        default:
            break
        }
    }
}

// ============================================================
// MARK: - Турнир
// ============================================================

/// Запускает игру N раз и собирает агрегированную статистику.
final class Tournament {
    let gamesCount: Int
    let playerNames: [String]

    init(gamesCount: Int, playerNames: [String]) {
        self.gamesCount = gamesCount
        self.playerNames = playerNames
    }

    /// Запустить турнир и напечатать итоговую статистику.
    func run() {
        print("")
        print("=== ТУРНИР ===")
        print("Партий: \(gamesCount)")
        print("Игроки: \(playerNames.joined(separator: ", "))")
        print("")

        var wins: [String: Int] = [:]
        playerNames.forEach { wins[$0] = 0 }

        var totalCycles = 0
        var totalRolls = 0
        var totalLadders = 0
        var totalSnakes = 0
        var totalStays = 0

        var minCycles = Int.max
        var maxCycles = 0

        for gameNumber in 1...gamesCount {
            let game = GameFactory.makeGame(players: playerNames)
            let stats = StatsCollector()

            // Подключаем только сборщик статистики — логгер молчит
            game.addObserver(stats)
            game.start()

            guard let winner = stats.winner else { continue }

            wins[winner, default: 0] += 1
            totalCycles += stats.cycles
            totalRolls += stats.rolls
            totalLadders += stats.laddersUsed
            totalSnakes += stats.snakesUsed
            totalStays += stats.stays
            minCycles = min(minCycles, stats.cycles)
            maxCycles = max(maxCycles, stats.cycles)

            // Прогресс каждые 100 партий
            if gameNumber % 100 == 0 {
                print("  ...сыграно \(gameNumber) из \(gamesCount)")
            }
        }

        print("")
        print("=== РЕЗУЛЬТАТЫ ===")
        print("")

        print("Победы:")
        let sortedWins = wins.sorted { $0.value > $1.value }
        for (player, count) in sortedWins {
            let percent = Double(count) / Double(gamesCount) * 100
            print(String(format: "  %@: %d (%.1f%%)", player, count, percent))
        }

        print("")
        print("Длительность партии (в циклах):")
        print(String(format: "  Минимум:  %d", minCycles))
        print(String(format: "  Максимум: %d", maxCycles))
        print(String(format: "  Среднее:  %.1f", Double(totalCycles) / Double(gamesCount)))

        print("")
        print("Активность за все партии:")
        print("  Всего бросков кубика: \(totalRolls)")
        print(String(format: "  Бросков на партию:    %.1f", Double(totalRolls) / Double(gamesCount)))
        print("  Сработало лестниц:    \(totalLadders)")
        print("  Сработало змей:       \(totalSnakes)")
        print("  Ходов «сгорело»:      \(totalStays)")
    }
}
