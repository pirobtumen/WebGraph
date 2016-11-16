# Basic options
CC=g++
LEX=flex

# Flags
# -DECHO: yylex() doesn't print in console.
LDFLAGS= -lcurl
CFLAGS= -std=c++11 -DECHO

# Files
LEX_C=webgraph.yy.c
LEX_SRC=webgraph.lex
EXEC=webgraph

# Compile
all: $(LEX_SRC)
	$(LEX) -o $(LEX_C) $(LEX_SRC)
	$(CC) $(LEX_C) -o $(EXEC) $(LDFLAGS) $(CFLAGS)

# Clean data
clean:
	rm *.yy.c $(EXEC)
