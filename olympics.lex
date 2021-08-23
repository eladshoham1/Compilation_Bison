%{
#include <string.h>
#include "olympics.tab.h"
extern void exit(int);

int line = 1;
%}

%option noyywrap
%option yylineno

%%

"<sport>"   { return SPORT; }

"<years>"   { return YEARS; }

189[6-9]|19[0-9]{2}|[2-9][0-9]{3,}  { 
                                        yylval.year = atoi(yytext); 
                                        yylval.year = yylval.year == 2021 ? 2020 : yylval.year; 
                                        return YEAR_NUM; 
                                    }

,   { return COMMA; }

"through"|- { return THROUGH; }

"since" { return SINCE; }

"all"   { return ALL; }

"["[A-Za-z]+(" "[A-Za-z]+)*"]"  { 
                                    strcpy(yylval.name, yytext+1); 
                                    yylval.name[strlen(yylval.name)-1] = '\0'; 
                                    return NAME; 
                                }

[A-Za-z]+(" "[A-Za-z]+)*    { return TITLE; }

[\t\r ]+    /* skip white space */

\n  { line++; }
                
.   { 
        fprintf(stderr, "line: %d unrecognized token %c (0x%x)\n", line, yytext[0], yytext[0]); 
        exit(EXIT_FAILURE); 
    }			

%%