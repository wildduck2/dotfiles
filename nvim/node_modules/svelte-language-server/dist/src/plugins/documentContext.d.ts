import { DocumentContext } from 'vscode-css-languageservice';
import { WorkspaceFolder } from 'vscode-languageserver';
export declare function getDocumentContext(documentUri: string, workspaceFolders: WorkspaceFolder[]): DocumentContext;
