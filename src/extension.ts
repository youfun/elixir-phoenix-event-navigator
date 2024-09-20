import * as vscode from 'vscode';
import { ElixirEventDefinitionProvider } from './definitionProvider';

export function activate(context: vscode.ExtensionContext) {
    console.log('Activating Elixir Event Definition Provider');

    const provider = new ElixirEventDefinitionProvider();
    const disposable = vscode.languages.registerDefinitionProvider(
        { scheme: 'file', language: 'elixir' },
        provider
    );

    context.subscriptions.push(disposable);

    console.log('Elixir Event Definition Provider activated');

    // 添加一个命令来测试提供器
    let testCommand = vscode.commands.registerCommand('elixir-event-navigator.testProvider', () => {
        console.log('Test command executed');
        vscode.window.showInformationMessage('Elixir Event Navigator is active!');
    });

    context.subscriptions.push(testCommand);
}

export function deactivate() {
    console.log('Deactivating Elixir Event Definition Provider');
}