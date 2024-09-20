# Elixir Event Navigator

Elixir Event Navigator is a Visual Studio Code extension designed for developers working with the LiveViewNative library in Phoenix projects. It facilitates easy navigation between Elixir event definitions and handlers, particularly useful for building native iOS apps with SwiftUI using Phoenix LiveView.

## Features

- Quick navigation between Elixir event definitions and their corresponding handlers
- Support for Phoenix LiveView and LiveViewNative projects
- Enhanced navigation experience in `.ex`, `.exs`, and `.swiftui.ex` files
- Bridges the gap where VS Code's official definition jump functionality falls short for specific languages and libraries

## Usage

1. Place your cursor on an event definition or handler in an Elixir file
2. Use the shortcut `[your_shortcut_here]` or the "Navigate to Event/Handler" command from the command palette
3. The extension will automatically jump to the related event definition or handler

## Requirements

- Visual Studio Code 1.60.0 or higher
- Phoenix project open in the workspace
- LiveViewNative Swift package installed

## Installation

1. Open VS Code
2. Go to the Extensions view (Ctrl+Shift+X)
3. Search for "Elixir Event Navigator"
4. Click Install

## Configuration

[List any configuration options here]

## Known Issues

[List any known issues or limitations]


## License

[Specify your license, e.g., MIT, Apache 2.0, etc.]

## More Information

- [LiveViewNative Swift package](https://github.com/liveview-native/liveview-native-swift)
- [Phoenix LiveView documentation](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html)

The LiveViewNative Swift package allows you to use Phoenix LiveView to build native iOS apps with SwiftUI. This extension aims to enhance the development experience by providing easy navigation between related Elixir code elements.

If you encounter any issues or have suggestions for improvements while using this extension, please raise an issue on our [GitHub repository](your_repository_link_here).

Thank you for using Elixir Event Navigator!