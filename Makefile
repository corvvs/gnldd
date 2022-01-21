GNL_DIR					:=	gnl

GNL_SRCS_MANDATORY		:=	get_next_line.c get_next_line_utils.c
GNL_FILES_MANDATORY		:=	$(GNL_SRCS_MANDATORY) get_next_line.h

GNL_WORKDIR_MANDATORY	:=	work_mandatory
GNL_WORKDIR_BONUS		:=	work_bonus

GNL_BUFFER_SIZES		:=	1 2 4 8 16 41 42 43 100 1000 1024 2048 4096 1000000

GNL_TESTFILEDIR			:=	test_files
GNL_TESTFILES			:=	0x0 0x1 1x1 1x0 1x10 10x1 10x10 42x0 42x1 0x42 1x42 42x42 42x100 1000x0 1000x1 1000x10 0x1000 1x1000 10x1000 1000x1000

EXEC_MANDATORY			:=	exec_mandatory
EXEC_BONUS				:=	exec_bonus

CC						:=	gcc
CCFLAGS					:=	-Wall -Wextra -Werror -fsanitize=address -D BUFFER_SIZE=$(BUFFER_SIZE)

$(GNL_TESTFILEDIR)		:
	mkdir -p $(GNL_TESTFILEDIR)

$(GNL_TESTFILES)		:	$(GNL_TESTFILEDIR)
	@echo "generating test file" $@ "..."
	@ruby -e 'AS = ("a".."z").to_a; W, H = "$@".split("x").map &:to_i; h = H; (H + 1).times{ |i| print (0...W).map{ AS[rand(AS.size)] }.join; puts if h > 0; h -= 1 }' > $@

$(GNL_WORKDIR_MANDATORY):
	mkdir -p $(GNL_WORKDIR_MANDATORY)

$(GNL_WORKDIR_BONUS)	:
	mkdir -p $(GNL_WORKDIR_BONUS)

deploy_mandatory		:	$(GNL_WORKDIR_MANDATORY)
	rm -rf $(GNL_WORKDIR_MANDATORY)/*
	cp $(GNL_DIR)/$(GNL_FILES_MANDATORY) $(GNL_WORKDIR_MANDATORY)/

$(EXEC_MANDATORY)		:	deploy_mandatory
	$(CC) $(CCFLAGS) -o $(EXEC_MANDATORY) $(GNL_WORKDIR_MANDATORY)/*.c main_mandatory.c

run						:
	echo $(GNL_BUFFER_SIZES) | tr ' ' '\n' | xargs -I{} $(MAKE) BUFFER_SIZE={} run_for;

run_for					:	run_fd run_stdin

run_fd					:	$(GNL_TESTFILES)
	echo $(GNL_TESTFILES) | tr ' ' '\n' | xargs -I{} ./$(EXEC_MANDATORY) {} > tout && diff -u {} tout;

run_stdin				:	$(GNL_TESTFILES)
	echo $(GNL_TESTFILES) | tr ' ' '\n' | xargs -I{} cat {} | ./$(EXEC_MANDATORY) > tout && diff -u {} tout;
