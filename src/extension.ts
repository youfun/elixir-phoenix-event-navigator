import * as vscode from 'vscode';
import { ElixirEventDefinitionProvider } from './definitionProvider';

export function activate(context: vscode.ExtensionContext) {
    const provider = new ElixirEventDefinitionProvider();

    context.subscriptions.push(
        vscode.languages.registerDefinitionProvider(
            { scheme: 'file', pattern: '**/*.swiftui.ex' },
            provider
        )
    );

    console.log('Elixir Event Navigator is now active!');
}

export function deactivate() {}