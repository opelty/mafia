//
//  GameMatch.swift
//  Mafia
//
//  Created by Jaime Andres Laino Guerra on 1/02/25.
//

import Dependencies
import Sharing
import SwiftUI
import SwiftUINavigation

@MainActor
@Observable
final class GameMatchModel {

    var match: Match
    @ObservationIgnored @Shared var game: Game

    init(game: Shared<Game>, matchId: Match.ID? = nil) {
        @Dependency(\.uuid) var uuid
        let match: Match = matchId.flatMap { game.matches[id: $0].wrappedValue } ?? Match(
            id: .init(uuid()),
            players: Match.assignRoles(players: game.wrappedValue.players)
        )

        self._game = game
        self.match = match
    }

    func nextTurnButtonTapped() {
        let mobstersAlive = match.players
            .filter {
                $0.role == .mobster
                && $0.state == .alive
            }
            .count
        let nonMobsterAlive = match.players
            .filter {
                $0.role != .mobster
                && $0.state == .alive
            }
            .count

        if mobstersAlive == 0 {
            match.state = .over(withWinner: .villagers)
        } else if nonMobsterAlive <= match.players.count / 3 {
            match.state = .over(withWinner: .mobsters)
        } else {
            match.state = match.state == .day ? .night : .day
        }

        $game.withLock {
            $0.matches[id: match.id] = match
            $0 = $0
        }
    }
}

struct GameMatchView: View {
    @State var player: Match.RolePlayer?
    @State var model: GameMatchModel

    init?(id: Game.ID, matchId: Match.ID? = nil) {
        @Shared(.games) var games
        guard let game = Shared($games[id: id])
        else { return nil }
        _model = State(wrappedValue: GameMatchModel(game: game, matchId: matchId))
    }

    var body: some View {
        List {
            if case let .over(winner) = model.match.state {
                Text("Game Over")
                Text("Winner: \(winner)")
            } else {
                Section {
                    Label(
                        model.match.state == .day ? "Day" : "Night",
                        systemImage: model.match.state == .day ? "sun.max.fill" : "moon.fill"
                    )
                    Button("Next Turn") {
                        model.nextTurnButtonTapped()
                    }
                    if model.match.state == .day {
                        HStack {
                            Spacer()
                            StopWatchContentView()
                            Spacer()
                        }
                    }
                } header: {
                    Text("Current Turn")
                }
            }

            Section {
                HStack {
                    StatView(
                        icon: "person.3.fill",
                        color: .red,
                        title: "Mobsters",
                        value: "\(model.match.players.filter { $0.role == .mobster && $0.state == .alive }.count)"
                    )

                    Spacer()

                    StatView(
                        icon: "person.fill",
                        color: .green,
                        title: "Villagers",
                        value: "\(model.match.players.filter { $0.role != .mobster && $0.state == .alive }.count)"
                    )

                    Spacer()

                    StatView(
                        icon: "heart.fill",
                        color: .blue,
                        title: "Alive",
                        value: String(format: "%1$d / %2$d", model.match.players.filter { $0.state == .alive }.count, model.match.players.count)
                    )
                }
            } header: {
                Text("Summary")
            }

            Section {
                ForEach(model.match.players) { player in
                    RolePlayerView(
                        player: player
                    )
                    .if(model.match.state == .day) {
                        $0.onTapGesture {
                            self.player = player
                        }
                        .sheet(item: $player) { player in
                            SelectedRolePlayerView(player: player)
                        }
                    }
                    .if(model.match.state != .day) {
                        $0.swipeActions {
                            Button("Kill") {
                                model.match.players[id: player.id]?.state = .dead
                            }
                            .tint(.red)
                        }
                        .swipeActions(edge: .leading) {
                            Button("Revive") {
                                model.match.players[id: player.id]?.state = .alive
                            }
                            .tint(.green)
                        }
                    }
                }
            } header: {
                Text("Players")
            }

        }
        .navigationTitle(model.game.title)
    }
}

struct StatView: View {
    let icon: String
    let color: Color
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .padding(8)
                .background(color.opacity(0.2))
                .clipShape(Circle())

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(.headline)
                .foregroundColor(.primary)
        }
    }
}

struct SelectedRolePlayerView: View {
    let player: Match.RolePlayer

    var body: some View {
        VStack {
            player.role.image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()

            Text(player.player.name)
                .font(.title)
            Text(player.role.localized)
                .font(.title2)
        }
    }
}

struct RolePlayerView: View {
    let player: Match.RolePlayer

    var body: some View {
        HStack {
            switch player.role {
            case .mobster:
                Label("Mobster", systemImage: "bandage")
            case .villager:
                Label("Villager", systemImage: "heart")
            case .king:
                Label("King", systemImage: "crown")
            case .doctor:
                Label("Doctor", systemImage: "cross")
            case .sheriff:
                Label("Sheriff", systemImage: "star")
            }

            Text(" - ")
            Text(player.player.name)
            Spacer()
            Image(
                systemName: player.state == .alive
                ? "person.fill"
                : "person.slash"
            )
            .renderingMode(.template)
            .foregroundColor(player.state == .alive ? .green : .red)
        }
        .opacity(player.state == .alive ? 1 : 0.3)
    }
}

#Preview {
    var game = Game.mock
    @Shared(.games) var games = [
        game
    ]
    NavigationStack {
        GameMatchView(id: game.id)
    }
}
