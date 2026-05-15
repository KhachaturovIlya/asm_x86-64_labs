#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <stddef.h>
#include <fcntl.h>
#include <stdint.h>
#include <sys/mman.h>
#include <sys/stat.h>

#include "black_bmp.h"

int main(int argc, char *argv[]) {
  if (argc != 3) {
    fprintf(stderr, "Wrong arguments were given!\n");
    return 1;
  }

  int ret = 0;

  int fd = open(argv[1], O_RDONLY);

  struct stat st;
  fstat(fd, &st);
  size_t file_size = st.st_size;

  int new_fd = open(argv[2], O_RDWR | O_CREAT | O_TRUNC, 0644);
  if (new_fd == -1) {
    close(fd);
    perror("Opening descriptor error.");
    return 1;
  }

  int error = copy_file_range(fd, NULL, new_fd, NULL, file_size, 0);
  close(fd);
  if (error == -1) {
    perror("Copy file error.");
    return 1;
  }

  uint8_t* img = (uint8_t*) mmap(
    NULL,
    file_size,
    PROT_READ | PROT_WRITE,
    MAP_SHARED,
    new_fd,
    0
  );

  close(new_fd);

  if (img == MAP_FAILED) {
    perror("Mapping error");
    return 1;
  }

  size_t offset   = *(uint32_t*) (img + 10);
  size_t width    = *(uint32_t*) (img + 18);
  size_t height   = *(uint32_t*) (img + 22);
  size_t bits_len = *(uint16_t*) (img + 28);

  if (bits_len != 24 && bits_len != 32) {
    printf("We are sorry, our programm not able to work with such formats (for now)...\n");
    printf("bit size : %lu\n", bits_len);
    goto exit; // Actually not an error.
  }

  size_t pixel_size = bits_len / 8;
  uint8_t* pixels_start = img + offset;

  black_bmp(pixels_start, pixel_size, width, height);

exit:
  munmap(img, file_size);

  return ret;
}
