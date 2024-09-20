import * as vscode from 'vscode';
import * as path from 'path';
import * as fs from 'fs';

export class ElixirEventDefinitionProvider implements vscode.DefinitionProvider {
    provideDefinition(
        document: vscode.TextDocument,
        position: vscode.Position,
        token: vscode.CancellationToken
    ): vscode.ProviderResult<vscode.Definition | vscode.LocationLink[]> {
        console.log('ElixirEventDefinitionProvider: provideDefinition called');
        
        const wordRange = document.getWordRangeAtPosition(position, /phx-\w+="(\w+)"/);
        if (!wordRange) {
            console.log('ElixirEventDefinitionProvider: No word range found');
            return null;
        }

        const line = document.lineAt(position.line).text;
        const match = /phx-\w+="(\w+)"/.exec(line.substring(wordRange.start.character));
        if (!match) {
            console.log('ElixirEventDefinitionProvider: No match found');
            return null;
        }

        const eventName = match[1];
        console.log('ElixirEventDefinitionProvider: Event name found:', eventName);

        const currentFilePath = document.uri.fsPath;
        const baseFileName = path.basename(currentFilePath, '.swiftui.ex');
        const exFilePath = path.join(path.dirname(currentFilePath), `${baseFileName}.ex`);

        console.log('ElixirEventDefinitionProvider: Searching in file:', exFilePath);

        if (!fs.existsSync(exFilePath)) {
            console.log('ElixirEventDefinitionProvider: File not found');
            return null;
        }

        const exFileContent = fs.readFileSync(exFilePath, 'utf8');
        const lines = exFileContent.split('\n');

        for (let i = 0; i < lines.length; i++) {
            if (lines[i].includes(`def handle_event("${eventName}"`)) {
                console.log('ElixirEventDefinitionProvider: Event handler found at line', i);
                return new vscode.Location(
                    vscode.Uri.file(exFilePath),
                    new vscode.Position(i, 0)
                );
            }
        }

        console.log('ElixirEventDefinitionProvider: Event handler not found');
        return null;
    }
}