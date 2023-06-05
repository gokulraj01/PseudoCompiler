REQ_FILES		= pseudo_parser.tab.c pseudo_defs.h lex.yy.c
COMPILER		= gcc
EXT				= .c
BUILD_DIR		= build

pseudo_run: $(REQ_FILES)
	mkdir -p build
	$(COMPILER) -O -c $(BUILD_DIR)/lex.yy.c -o $(BUILD_DIR)/lexer.o
	$(COMPILER) -O -c $(BUILD_DIR)/pseudo_parser.tab.c -o $(BUILD_DIR)/parser.o
	$(COMPILER) $(BUILD_DIR)/lexer.o $(BUILD_DIR)/parser.o -o pseudo_run -lfl

pseudo_parser.tab.c pseudo_defs.h: pseudo_parser.y
	mkdir -p build
	bison --header="$(BUILD_DIR)/pseudo_defs.h" -Wcounterexamples pseudo_parser.y -o "$(BUILD_DIR)/pseudo_parser.tab.c"

lex.yy.c: pseudo_lexer.l
	mkdir -p build
	flex -i -o "$(BUILD_DIR)/lex.yy.c" pseudo_lexer.l

clean:
	rm -r build
	rm pseudo_run