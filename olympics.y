%code {
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex(void);
void yyerror(const char *s);

int timesInOlympics(int start, int end);
}

%code requires {
    enum constants { YEARS_BETWEEN_OLYMPICS = 4, MIN_OLYMPICS = 7, MAX_SIZE = 100, FIRST_OLYMPICS_YEAR = 1896, LAST_OLYMPICS_YEAR = 2020 };

    struct olympics {
        char **releventSports;
        int numOfReleventSports;
        int numOfSports;
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
                                if ($2.numOfReleventSports != 0)
                                {
                                    printf("sports which appeared in at least %d olympic games:\n", MIN_OLYMPICS);
                                    for (int i = 0; i < $2.numOfReleventSports; i++)
                                        printf("%s\n", $2.releventSports[i]);
                                }
                                else
                                    printf("there is no such a sports which appeared in at least %d olympic games\n", MIN_OLYMPICS);

                                printf("average number of games per sport: %.2f\n", $2.numOfSports != 0 ? ($2.sum / (float)$2.numOfSports) : 0);

                                for (int i = 0; i < $2.numOfReleventSports; i++)
                                    free($2.releventSports[i]);
                                free($2.releventSports);
                            };

list_of_sports: list_of_sports sport_info   {
                                                $$.numOfSports++;
                                                $$.sum += $2.timesInOlympics;

                                                if ($2.timesInOlympics >= MIN_OLYMPICS)
                                                {
                                                    $$.releventSports = (char**)realloc($$.releventSports, ($$.numOfReleventSports + 1) * sizeof(char*));
                                                    if (!$$.releventSports)
                                                    {
                                                        fprintf(stderr, "realloc failed\n");
                                                        exit(EXIT_FAILURE);
                                                    }

                                                    $$.releventSports[$$.numOfReleventSports++] = strdup($2.name);
                                                }
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
        return EXIT_FAILURE;
    }

    yyin = fopen (argv [1], "r");
    if (yyin == NULL) {
        fprintf (stderr, "failed to open %s\n", argv[1]);
        return EXIT_FAILURE;
    }

    yyparse();
    
    fclose (yyin);
    return EXIT_SUCCESS;
}

void yyerror(const char *s)
{
    extern int line;
    fprintf(stderr, "line %d: %s\n", line, s);
}

int timesInOlympics(int start, int end)
{
    return (end - start) / YEARS_BETWEEN_OLYMPICS + 1;
}