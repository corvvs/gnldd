#include <libc.h>
#include "work_mandatory/get_next_line.h"

int main(int argc, char **argv)
{
	setvbuf(stdout, (char *)NULL, _IONBF, 0);
	const int	read_from_stdin = argc > 1;
	int			fd = read_from_stdin ? open(argv[1], O_RDONLY) : STDIN_FILENO;

	if (fd < 0)
	{
		dprintf(STDERR_FILENO, "failed to open \"%s\"\n", argv[1]);
		exit(1);
	}

	char	*line;
	while (1)
	{
		line = get_next_line(fd);
		if (!line)
			break ;
		printf("%s", line);
		free(line);
	}
	if (read_from_stdin)
		close(fd);
}
