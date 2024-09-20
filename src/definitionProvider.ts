import * as vscode from 'vscode';
import * as path from 'path';
import * as fs from 'fs';

export class ElixirEventDefinitionProvider implements vscode.DefinitionProvider {
    provideDefinition(
        document: vscode.TextDocument,
        position: vscode.Position,
        token: vscode.CancellationToken
    ): vscode.ProviderResult<vscode.Definition | vscode.LocationLink[]> {
        const line = document.lineAt(position.line).text;
        const regex = /phx-\w+="(\w+)"/g;
        let match;
        let eventName = null;

        while ((match = regex.exec(line)) !== null) {
            const start = match.index;
            const end = start + match[0].length;
            if (position.character >= start && position.character <= end) {
                eventName = match[1];
                break;
            }
        }

        if (!eventName) {
            return null;
        }

        const currentFilePath = document.uri.fsPath;
        const baseFileName = path.basename(currentFilePath, '.swiftui.ex');
        const exFilePath = path.join(path.dirname(currentFilePath), `${baseFileName}.ex`);

        if (!fs.existsSync(exFilePath)) {
            return null;
        }

        const exFileContent = fs.readFileSync(exFilePath, 'utf8');
        const lines = exFileContent.split('\n');

        for (let i = 0; i < lines.length; i++) {
            if (lines[i].includes(`def handle_event("${eventName}"`)) {
                return new vscode.Location(
                    vscode.Uri.file(exFilePath),
                    new vscode.Position(i, 0)
                );
            }
        }

        return null;
    }
}