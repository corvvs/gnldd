#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

#ifndef MALLOC_FAIL_RATE
# define MALLOC_FAIL_RATE	0.00
#endif

static int malloc_total = 0;
static int malloc_succ = 0;
static int free_succ = 0;

void	*dd_malloc(size_t size, const char *file, int line, const char *func)
{
	(void)file;
	(void)line;
	(void)func;
	void *d = ((double)random()) / RAND_MAX >= MALLOC_FAIL_RATE
		? malloc(size) : NULL;
	malloc_total += 1;
	if (d)
		malloc_succ += 1;
#ifdef DD_VISUALIZE
	if (d)
		dprintf(STDERR_FILENO, "\e[90mmalloc:\t%8p %d / %d size = %zu %s:%d %s\e[m\n", d, malloc_succ, malloc_total, size, file, line, func);
	else
		dprintf(STDERR_FILENO, "\e[93m*FAIL* malloc %d size = %zu %s:%d %s\e[m\n", malloc_total, size, file, line, func);
#endif
	return (d);
}

void	dd_free(void *data, const char *file, int line, const char *func)
{
	(void)file;
	(void)line;
	(void)func;
	if (data)
	{
		free_succ += 1;
#ifdef DD_VISUALIZE
		dprintf(STDERR_FILENO, "\e[90mfree:\t%8p %d %s:%d %s\e[m\n", data, free_succ, file, line, func);
#endif
	}
#ifdef DD_VISUALIZE
	else
		dprintf(STDERR_FILENO, "\e[93mfreeing NULL; %d %s:%d %s\e[m\n", free_succ, file, line, func);
#endif
	free(data);
}

int	dd_malloc_balance(int bias)
{
	int	balanced = (malloc_succ - free_succ + bias) == 0;
	dprintf(STDERR_FILENO, "%s[%s] malloc: %d, free: %d (bias %+d)\e[m\n",
		balanced ? "\e[92m" : "\e[91m",
		balanced ? "balanced" : "IMBALANCED",
		malloc_succ,
		free_succ,
		bias
	);
	return (balanced);
}

#ifndef READ_FAIL_RATE
# define READ_FAIL_RATE	0.00
#endif

ssize_t	dd_read(int fd, void *buffer, size_t size, const char *file, int line, const char *func)
{
	double dice = (((double)random()) / RAND_MAX);
	if (dice >= READ_FAIL_RATE)
	{
		ssize_t rv = read(fd, buffer, size);
#ifdef DD_VISUALIZE
		if (rv >= 0)
			dprintf(STDERR_FILENO, "\e[90mread(%d, *buffer, %zu) -> %zd %s:%d %s\e[m\n", fd, size, rv, file, line, func);
		else
			dprintf(STDERR_FILENO, "\e[93m*FAIL* read(%d, *buffer, %zu) %s:%d %s\e[m\n", fd, size, file, line, func);
#endif
		return (rv);
	}
	else
	{
#ifdef DD_VISUALIZE
		dprintf(STDERR_FILENO, "\e[93m*FAIL* read fd = %d %s:%d %s\e[m\n", fd, file, line, func);
#endif
		return (-1);
	}
}
