REQ_FILES		= $(BUILD_DIR)/pseudo_parser.tab.c $(BUILD_DIR)/pseudo_defs.h $(BUILD_DIR)/lex.yy.c
COMPILER		= gcc
EXT				= .c
BUILD_DIR		= build

pseudo_run: $(REQ_FILES)
	mkdir -p build
	$(COMPILER) $(BUILD_DIR)/lex.yy.c $(BUILD_DIR)/pseudo_parser.tab.c -o pseudo_run -lfl

$(BUILD_DIR)/pseudo_parser.tab.c $(BUILD_DIR)/pseudo_defs.h: pseudo_parser.y
	mkdir -p build
	bison --header="$(BUILD_DIR)/pseudo_defs.h" --graph="$(BUILD_DIR)/syntax_graph.dot" -Wcounterexamples pseudo_parser.y -o "$(BUILD_DIR)/pseudo_parser.tab.c"
	# dot "$(BUILD_DIR)/syntax_graph.dot" -T png -o syntax_graph.png

$(BUILD_DIR)/lex.yy.c: pseudo_lexer.l
	mkdir -p build
	flex -i -o "$(BUILD_DIR)/lex.yy.c" pseudo_lexer.l

debug: $(REQ_FILES)
	mkdir -p build
	$(COMPILER) -g $(BUILD_DIR)/lex.yy.c $(BUILD_DIR)/pseudo_parser.tab.c -o pseudo_run -lfl

clean:
	rm -r build
	rm pseudo_run