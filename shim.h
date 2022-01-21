#ifndef GNLDD_SHIM_H
# define GNLDD_SHIM_H

# define malloc(size) dd_malloc(size, __FILE__, __LINE__, __func__)
# define free(data) dd_free(data, __FILE__, __LINE__, __func__)
# define read(fd, buffer, size) dd_read(fd, buffer, size, __FILE__, __LINE__, __func__)
# include <stdlib.h>
# include <stdio.h>
# include <unistd.h>

ssize_t	dd_read(int fd, void *buffer, size_t size, const char *file, int line, const char *func);
void	*dd_malloc(size_t size, const char *file, int line, const char *func);
void	dd_free(void *data, const char *file, int line, const char *func);
int		dd_malloc_balance(int bias);

#endif
