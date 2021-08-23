%code {
#include <stdio.h>

extern int yylex(void);
void yyerror(const char *s);

enum str { MAX_SIZE = 100 };

struct time min_time(struct time t1, struct time t2);
}

%union {
    char listOfSports[MAX_SIZE][MAX_SIZE];
    char name[MAX_SIZE];
    int year;
    int sum;
    float avg;
}

%token TITLE SPORT YEARS NAME YEAR_NUM COMMA THROUGH SINCE ALL
%token <name> NAME
%token <year> YEAR_NUM

%nterm <listOfSports> list_of_sports

%error-verbose

%%

start: PLAYLIST songlist 
       { if ($2.minutes == -1) 
             printf ("no relevant song\n");
         else
             printf ("time for shortest relevant song: %d:%.2d\n",
                            $2.minutes, $2.seconds);
       };
       
songlist: /* empty */   { $$.minutes = -1;
                          $$.seconds = -1;
                        };
                        
songlist: songlist song { $$ = min_time($1, $2); };

song: SEQ_NUM  SONG SONG_NAME  ARTIST artist_name LENGTH SONG_LENGTH
       {  if ($5 == 1 && ($7.minutes > 4 || $7.minutes == 4 &&
                                            $7.seconds >= 2))
              $$ = $7;
          else {
              $$.minutes = -1;
              $$.seconds = -1;
          }
       };

artist_name: NAME { $$ = 1; }
           | NAME NAME { $$ = 2; }
           ;           


input: TITLE list_of_sports;
list_of_sports: list_of_sports sport_info;
list_of_sports: /* empty */;
sport_info: SPORT NAME YEARS list_of_years;
list_of_years: list_of_years ',' year_spec;
list_of_years: year_spec;
year_spec: YEAR_NUM |
 ALL |
 YEAR_NUM THROUGH YEAR_NUM |
 SINCE YEAR_NUM
 ;


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
  
    yyparse();
    
    fclose (yyin);
    return 0;
}

void yyerror(const char *s)
{
    extern int line;
    fprintf(stderr, "line %d: %s\n", line, s);
}

struct time min_time(struct time t1, struct time t2)
{
    if (t1.minutes == -1)
        return t2;
    else if (t2.minutes == -1)
        return t1;
        
    if (t1.minutes < t2.minutes || (t1.minutes == t2.minutes &&
                                    t1.seconds < t2.seconds))
        return t1;
    return t2;
}