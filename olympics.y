%code {
#include <stdio.h>

extern int yylex(void);
extern char* strcpy(char*, const char*);
void yyerror(const char *s);

int timesInOlympics(int start, int end);
}

%code requires {
    enum constants { MAX_SIZE = 100, FIRST_OLYMPICS_YEAR = 1896, LAST_OLYMPICS_YEAR = 2020 };

    struct olympics {
        int numOfAllSports;
        int sum;
    };

    struct sport {
        char name[MAX_SIZE];
        int timesInOlympics;
    };
}

%union {
    char name[MAX_SIZE];
    int year; 
    struct olympics _olympics;
    struct sport _sport;
    int timesInOlympics;
}

%token TITLE SPORT YEARS COMMA THROUGH SINCE ALL
%token <name> NAME
%token <year> YEAR_NUM

%nterm <_olympics> list_of_sports
%nterm <_sport> sport_info
%nterm <timesInOlympics> list_of_years
%nterm <timesInOlympics> year_spec

%error-verbose

%%

input: TITLE list_of_sports { 
                                if ($2.numOfAllSports != 0)
                                    printf("average number of games per sport: %.2f\n", ($2.sum / (float)$2.numOfAllSports)); 
                                else
                                    printf("there is no such sports\n");
                            };

list_of_sports: list_of_sports sport_info   {
                                                $$.numOfAllSports++;
                                                $$.sum += $2.timesInOlympics;

                                                if ($2.timesInOlympics >= 7)
                                                    printf("%s\n", $2.name);
                                            }
    | %empty { };

sport_info: SPORT NAME YEARS list_of_years  { 
                                                strcpy($$.name, $2);
                                                $$.timesInOlympics = $4;
                                            };

list_of_years: list_of_years COMMA year_spec { $$ = $1 + $3; }
    | year_spec { $$ = $1; };

year_spec: YEAR_NUM { $$ = 1; } 
    | ALL { $$ = timesInOlympics(FIRST_OLYMPICS_YEAR, LAST_OLYMPICS_YEAR); } 
    | YEAR_NUM THROUGH YEAR_NUM { $$ = timesInOlympics($1, $3); } 
    | SINCE YEAR_NUM { $$ = timesInOlympics($2, LAST_OLYMPICS_YEAR); };

%%

int main(int argc, char **argv)
{
    extern FILE *yyin;
    if (argc != 2) {
        fprintf (stderr, "Usage: ./%s <input-file-name>\n", argv[0]);
        return 1;
    }

    yyin = fopen (argv [1], "r");
    if (yyin == NULL) {
        fprintf (stderr, "failed to open %s\n", argv[1]);
        return 1;
    }

    printf("sports which appeared in at least 7 olympic games:\n");
    yyparse();
    
    fclose (yyin);
    return 0;
}

void yyerror(const char *s)
{
    extern int line;
    fprintf(stderr, "line %d: %s\n", line, s);
}

int timesInOlympics(int start, int end)
{
    return (end - start) / 4 + 1;
}