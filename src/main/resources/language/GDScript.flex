package com.wilfcastle.gdscript;

import com.intellij.psi.tree.IElementType;
import com.wilfcastle.gdscript.psi.GDScriptTypes;
import com.intellij.psi.TokenType;

%%

%class GDScriptLexer
%implements FlexLexer
%unicode
%function advance
%type IElementType
%eof{  return;
%eof}

DIGIT=[0-9]
LETTER=[a-zA-Z]

IDENTIFIER=[a-zA-Z_][a-zA-Z0-9_]*

NUMBER = {DIGIT}+
HEX_DIGIT = [A-F0-9]
HEX_NUMBER = "0x"{HEX_DIGIT}+
FLOATING_NUMBER = {DIGIT}*"."{DIGIT}+

CRLF=\R
WHITE_SPACE=[\ \n\t\f]
FIRST_VALUE_CHARACTER=[^ \n\f\\] | "\\"{CRLF} | "\\".
VALUE_CHARACTER=[^\n\f\\] | "\\"{CRLF} | "\\".
END_OF_LINE_COMMENT=("#"|"!")[^\r\n]*
SEPARATOR=[:=]
KEY_CHARACTER=[^:=\ \n\t\f\\] | "\\ "

%state WAITING_VALUE

%%

("var")                                                     { return GDScriptTypes.VAR; }

({NUMBER}|{HEX_NUMBER}|{FLOATING_NUMBER})                   { return GDScriptTypes.NUMBER; }

<YYINITIAL> {END_OF_LINE_COMMENT}                           { yybegin(YYINITIAL); return GDScriptTypes.COMMENT; }

<YYINITIAL> {KEY_CHARACTER}+                                { yybegin(YYINITIAL); return GDScriptTypes.KEY; }

<YYINITIAL> {SEPARATOR}                                     { yybegin(WAITING_VALUE); return GDScriptTypes.SEPARATOR; }

<WAITING_VALUE> {CRLF}({CRLF}|{WHITE_SPACE})+               { yybegin(YYINITIAL); return TokenType.WHITE_SPACE; }

<WAITING_VALUE> {WHITE_SPACE}+                              { yybegin(WAITING_VALUE); return TokenType.WHITE_SPACE; }

<WAITING_VALUE> {FIRST_VALUE_CHARACTER}{VALUE_CHARACTER}*   { yybegin(YYINITIAL); return GDScriptTypes.VALUE; }

({CRLF}|{WHITE_SPACE})+                                     { yybegin(YYINITIAL); return TokenType.WHITE_SPACE; }

[^]                                                         { return TokenType.BAD_CHARACTER; }

