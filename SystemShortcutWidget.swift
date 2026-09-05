
import AppIntents
import SwiftUI
import WidgetKit

struct Entry: TimelineEntry {
    var date: Date = Date()
    var shortcut: SystemShortcut?
}

struct Provider: AppIntentTimelineProvider {

    func placeholder(in context: Context) -> Entry {
        .init()
    }

    func snapshot(
        for configuration: SystemShortcutConfigurationIntent,
        in context: Context
    ) async -> Entry {
        return Entry(shortcut: configuration.shortcut)
    }

    func timeline(
        for configuration: SystemShortcutConfigurationIntent,
        in context: Context
    ) async -> Timeline<Entry> {

        let entry = Entry(shortcut: configuration.shortcut)

        let timeline = Timeline(
            entries: [entry],
            policy: .never
        )

        return timeline
    }
}

struct SystemShortcutConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Shortcut Widget" }
    static var description: IntentDescription {
        "Widget that runs a shortcut or opens an app"
    }

    // An optional is required here.
    // Otherwise, will have the following error while building the extension: Encountered a non-optional type for parameter 'shortcut', but all parameter types must be optional for the following protocols: AppIntents.ControlConfigurationIntent, AppIntents.WidgetConfigurationIntent, and AppIntents.SetFocusFilterIntent
    @Parameter(title: "Action")
    var shortcut: SystemShortcut?
}

struct SystemShortcutWidget: Widget {
    let kind: String = "SystemShortcut"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SystemShortcutConfigurationIntent.self,
            provider: Provider()
        ) { entry in
            if let shortcut = entry.shortcut {
                VStack(spacing: 16) {
                    Text(shortcut.displayRepresentation.title)
                        .font(.headline)
                    Button(
                        // RunSystemShortcutIntent:
                        // Allows the user to:
                        // - Open any other app
                        // - Perform an App Shortcut
                        // - Run any custom shortcut that they create themselves within the Shortcut app, or
                        // - Perform a system action.
                        intent: RunSystemShortcutIntent(
                            shortcut: shortcut
                        )
                    ) {
                        Text("GO!")
                    }
                }

            } else {
                Text(
                    """
                    No shortcut defined!
                    1. Long press the widget
                    2. Choose Edit Widget
                    3. Select a shortcut
                    """
                )
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget on System shortcut.")
    }
}


@main
struct SystemShortcutBundle: WidgetBundle {
    var body: some Widget {
        SystemShortcutWidget()
    }
}

