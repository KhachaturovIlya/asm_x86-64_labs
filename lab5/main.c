#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <stddef.h>
#include <fcntl.h>
#include <stdint.h>
#include <sys/mman.h>
#include <sys/stat.h>

static void black_bmp(uint8_t* img, size_t pixel_size, size_t width, size_t height) {
  size_t rows_size = ((width * pixel_size + 3) / 4) * 4;

  for (size_t y = 0; y < height; y++) {
    for (size_t x = 0; x < width; x++) {
      uint8_t* pixel = img + (y * rows_size) + (x * pixel_size);

      uint8_t max = 0;
      uint8_t min = 255;

      max = pixel[0] > max ? pixel[0] : max;
      max = pixel[1] > max ? pixel[1] : max;
      max = pixel[2] > max ? pixel[2] : max;

      min = pixel[0] < min ? pixel[0] : min;
      min = pixel[1] < min ? pixel[1] : min;
      min = pixel[2] < min ? pixel[2] : min;

      uint8_t collor = (uint8_t) (((uint16_t) max + (uint16_t) min) / 2);

      pixel[0] = collor;
      pixel[1] = collor;
      pixel[2] = collor;
    }
  }
}

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
