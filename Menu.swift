import Foundation

// ============================================================
// MARK: - Консольное меню
// ============================================================

enum Menu {

    /// Точка входа: показать меню, обработать выбор, запустить игру.
    static func run() {
        while true {
            printMenu()
            let choice = readLine()?.trimmingCharacters(in: .whitespaces) ?? ""

            switch choice {
            case "1":
                runSingleGame()
                return

            case "2":
                runTournament()
                return

            case "0":
                print("Выход.")
                return

            default:
                print("⚠️ Неизвестный выбор. Попробуйте ещё раз.\n")
            }
        }
    }

    // ------------------------------------------------------------
    // MARK: - Вывод меню
    // ------------------------------------------------------------

    private static func printMenu() {
        print("")
        print("========================================")
        print("  Змеи и Лестницы")
        print("========================================")
        print("Выберите режим:")
        print("  1 — одиночная игра (подробный лог)")
        print("  2 — турнир из N раундов (статистика)")
        print("  0 — выход")
        print("")
        print("Ваш выбор: ", terminator: "")
    }

    // ------------------------------------------------------------
    // MARK: - Режим 1: одиночная игра
    // ------------------------------------------------------------

    private static func runSingleGame() {
        print("")
        let game = GameFactory.makeGame()
        let logger = GameLogger()          // печатает в консоль
        game.addObserver(logger)
        game.start()
    }

    // ------------------------------------------------------------
    // MARK: - Режим 2: турнир
    // ------------------------------------------------------------

    private static func runTournament() {
        print("")
        print("Введите количество партий: ", terminator: "")

        guard let input = readLine()?.trimmingCharacters(in: .whitespaces),
              let count = Int(input),
              count > 0 else {
            print("⚠️ Некорректное число. Возврат в меню.")
            return
        }

        let tournament = Tournament(
            gamesCount: count,
            playerNames: GameFactory.defaultPlayerNames
        )
        tournament.run()

        print("")
        print("Нажмите Enter, чтобы вернуться в меню...")
        _ = readLine()
    }
}
