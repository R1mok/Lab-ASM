//
// Created by airat on 16.05.2021.
//

#ifndef LAB5_MAIN_H
#define LAB5_MAIN_H

#include <stdio.h>
#include <time.h>

#define STB_IMAGE_IMPLEMENTATION
#define STB_IMAGE_WRITE_IMPLEMENTATION

#include "stb_image.h"
#include "stb_image_write.h"

unsigned char *reflect(unsigned char *data, int x, int y, int n);

int convert(char *input, char *output);

int main(int argc, char *argv[]);

unsigned char *reflectasm(unsigned char *data, int x, int y, int n);

#endif //LAB5_MAIN_H
