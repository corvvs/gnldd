GNL_DIR					:=	gnl

GNL_SRCS_MANDATORY		:=	get_next_line.c get_next_line_utils.c
GNL_FILES_MANDATORY		:=	$(GNL_SRCS_MANDATORY) get_next_line.h

GNL_WORKDIR_MANDATORY	:=	work_mandatory
GNL_WORKDIR_BONUS		:=	work_bonus

GNL_BUFFER_SIZES		:=	1 2 4 8 16 41 42 43 100 1000 1024 2048 4096 1000000

GNL_TESTFILEDIR			:=	test_files
GNL_TESTFILES			:=	0x1x0 0x1x1 1x1x1 1x1x0 1x10x1 10x1x0 10x1x1 10x10x1 42x1x0 42x1 0x42x0 1x42x1 42x42x1 42x100x1 1000x1x0 1000x1x1 1000x10x1 0x1000x1 1x1000x1 10x1000x1 1000x1000x1

EXEC_MANDATORY			:=	exec_mandatory
EXEC_BONUS				:=	exec_bonus

CC						:=	gcc
CCFLAGS					:=	-Wall -Wextra -Werror -fsanitize=address -D BUFFER_SIZE=$(BUFFER_SIZE)

$(GNL_TESTFILEDIR)		:
	mkdir -p $(GNL_TESTFILEDIR)

$(GNL_TESTFILES)		:
	@echo "generating test file" $@ "..."
	@ruby -e 'AS = ("a".."z").to_a; W, H, NL = "$@".split("x").map &:to_i; H.times{ |i| print (0...W).map{ AS[rand(AS.size)] }.join; print "\n" if i < H - 1 || NL == 1 }' > $@

tfwipe					:
	rm -f $(GNL_TESTFILES)

$(GNL_WORKDIR_MANDATORY):
	mkdir -p $(GNL_WORKDIR_MANDATORY)

$(GNL_WORKDIR_BONUS)	:
	mkdir -p $(GNL_WORKDIR_BONUS)

deploy_mandatory		:	$(GNL_WORKDIR_MANDATORY)
	rm -rf $(GNL_WORKDIR_MANDATORY)/*
	cp $(GNL_DIR)/$(GNL_FILES_MANDATORY) $(GNL_WORKDIR_MANDATORY)/

$(EXEC_MANDATORY)		:	deploy_mandatory
	$(CC) $(CCFLAGS) -o $(EXEC_MANDATORY) $(GNL_WORKDIR_MANDATORY)/*.c main_mandatory.c shim.c

run						:
	echo $(GNL_BUFFER_SIZES) | tr ' ' '\n' | xargs -I{} $(MAKE) BUFFER_SIZE={} run_for;

run_for					:	run_fd run_stdin

run_fd					:	$(GNL_TESTFILES)
	echo $(GNL_TESTFILES) | tr ' ' '\n' | xargs -I{} ./$(EXEC_MANDATORY) {} > tout && diff -u {} tout;

run_stdin				:	$(GNL_TESTFILES)
	echo $(GNL_TESTFILES) | tr ' ' '\n' | xargs -I{} cat {} | ./$(EXEC_MANDATORY) > tout && diff -u {} tout;

fclean	:
	$(RM) -f $(EXEC_MANDATORY) $(EXEC_BONUS)
