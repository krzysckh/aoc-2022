#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <err.h>

/* from the "use eyes" part of README */
#define max_x 30
#define max_y 30
#define max_z 30

void fillup(uint8_t **map, int x, int y) {
  map[x][y] = 2;
  if (y+1 < max_z) if (map[x][y+1] == 0) fillup(map, x, y+1);
  if (y-1 >= 0)    if (map[x][y-1] == 0) fillup(map, x, y-1);
  if (x+1 < max_x) if (map[x+1][y] == 0) fillup(map, x+1, y);
  if (x-1 >= 0)    if (map[x-1][y] == 0) fillup(map, x-1, y);
}

void p1(char* in, void* is_p2) {
  uint8_t ***map;
  int x,
      y,
      z,
      sz,
      area = 0;
  char *buf = malloc(128);

  /* ugly */
  map = malloc(sizeof(uint8_t**) * max_y);
  for (y = 0; y < max_y; y++) {
    map[y] = malloc(sizeof(uint8_t*) * max_x);
    for (x = 0; x < max_z; x++) {
      map[y][x] = malloc(sizeof(uint8_t) * max_z);
      memset(map[y][x], 0, max_z);
    }
  }

  while (*in) {
    /* parse input */
    sz = 0;
    memset(buf, 0, 128);
    while (*in++ != '\n')
      sz++;

    strncpy(buf, in - sz - 1, sz);
    sscanf(buf, "%d,%d,%d", &x, &y, &z);
    map[y][x][z] = 1;
  }

  for (y = 0; y < max_y; y++) {
    for (x = 0; x < max_x; x++) {
      for (z = 0; z < max_z; z++) {
        if (map[y][x][z] == 1) {
          area += 6;
          if (z > 0)
            if (map[y][x][z-1]) area--;
          if (z + 1 < max_z)
            if (map[y][x][z+1]) area--;
          if (x > 0)
            if (map[y][x-1][z]) area--;
          if (x + 1 < max_x)
            if (map[y][x+1][z]) area--;
          if (y > 0)
            if (map[y-1][x][z]) area--;
          if (y+1 < max_x)
            if (map[y+1][x][z]) area--;
        }
      }
    }
  } 

  if (is_p2) {
    for (y = 0; y < max_y; y++)
      fillup(map[y], max_x - 1, max_z - 1);

    for (y = 0; y < max_y; y++) {
      for (x = 0; x < max_x; x++) {
        for (z = 0; z < max_z; z++) {
          if (map[y][x][z] == 0) map[y][x][z] = 1;
        }
      }
    }

    /*for (y = 0; y < max_y; y++) {*/
      /*for (x = 0; x < max_x; x++) {*/
        /*printf("%d\t", x);*/
        /*for (z = 0; z < max_z; z++) {*/
          /*switch (map[y][x][z]) {*/
            /*case 2: putchar(' '); break;*/
            /*case 1: putchar('#'); break;*/
            /*case 0: putchar('/'); break;*/
            /*default: exit(1);*/
          /*}*/
        /*}*/
        /*printf("\n");*/
      /*}*/
      /*printf("\n");*/
    /*}*/

    char *fuck = malloc(1000000);
    char *f_orig = fuck;
    for (y = 0; y < max_y; y++) {
      for (x = 0; x < max_x; x++) {
        for (z = 0; z < max_z; z++) {
          if (map[y][x][z] == 1) {
            sprintf(fuck, "%d,%d,%d\n", x, y, z);
            fuck += strlen(fuck);
          }
        }
      }
    }
    fuck = f_orig;
    p1(fuck, NULL);
    free(fuck);
  }

  if (!is_p2)
    printf("p%d: %d\n", is_p2 == NULL ? 1 : 2, area);

  for (y = 0; y < max_y; y++) {
    for (x = 0; x < max_z; x++)
      free(map[y][x]);
    free(map[y]);
  }
  free(map);
  free(buf);
}

void p2(char *in) {
  p1(in, (void*)0xdeadbeef);
}

int main(void) {
  FILE *fp = fopen("./in", "r");
  char *in;
  int sz;

  if (!fp)
    err(1, "./in");

  fseek(fp, 0, SEEK_END);
  sz = ftell(fp);
  fseek(fp, 0, SEEK_SET);

  in = malloc(sz + 1);
  fread(in, 1, sz, fp);
  in[sz] = 0;

  p1(in, NULL);
  p2(in);

  free(in);
  fclose(fp);
}
