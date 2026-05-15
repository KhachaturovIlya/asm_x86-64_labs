#include <stdint.h>
#include <stddef.h>

void black_bmp(uint8_t* img, size_t pixel_size, size_t width, size_t height) {
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


