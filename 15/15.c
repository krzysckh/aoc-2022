#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_SZ 4000001

typedef struct {
  int x;
  int y;
  int bcn_x;
  int bcn_y;
  int bcn_sz;
} Sensor;

typedef struct {
  int start;
  int end;
} Line;

typedef struct {
  Line *line;
  int n;
} Full_line;

int strrpt(char *s, char c) {
  int ret = 0;
  while (*s)
    if (*s++ == c)
      ++ret;

  return ret;
}

int main (void) {
  FILE *fp = fopen("./in-pre", "r");
  int sz,
      sensors_n,
      i,
      put;
  char *in,
       *numbuf = malloc(16),
       *in_orig;
  Sensor *sensors;
  Full_line *lines = malloc(sizeof(Full_line) * (1 + MAX_SZ));
  Line *real_lines = malloc(sizeof(Line) * (1 + MAX_SZ));

  for (i = 0; i < MAX_SZ; ++i) {
    lines[i].line = NULL;
    lines[i].n = 0;
  }

  fseek(fp, 0, SEEK_END);
  sz = ftell(fp);
  fseek(fp, 0, SEEK_SET);

  in = malloc(sz + 1);
  fread(in, 1, sz, fp);
  in[sz] = 0;
  in_orig = in;

  sensors_n = strrpt(in, '\n');
  sensors = malloc(sizeof(Sensor) * sensors_n);

  sz = i = put = 0;
  while (*in) {
    if (*in == ' ' || *in == '\n') {
      strncpy(numbuf, in - sz, sz);
      switch (put) {
        case 0:
          sensors[(int)(i / 4)].x = atoi(numbuf);
          break;
        case 1:
          sensors[(int)(i / 4)].y = atoi(numbuf);
          break;
        case 2:
          sensors[(int)(i / 4)].bcn_x = atoi(numbuf);
          break;
        case 3:
          sensors[(int)(i / 4)].bcn_y = atoi(numbuf);
          break;
      }
      memset(numbuf, 0, 16);

      put = ++put % 4, sz = 0, in++, i++;
    } else sz++, in++;
  }

  for (i = 0; i < sensors_n; i++) {
    /* calc bcn_sz */
    sensors[i].bcn_sz = abs(sensors[i].x - sensors[i].bcn_x) +
      abs(sensors[i].y - sensors[i].bcn_y);
  }

  for (i = 0; i < sensors_n; i++) {
    /* fill lines */
    Sensor *cur = &sensors[i];
    int j, skip = -cur->bcn_sz;
    /* y from up to down */
    for (j = cur->y - cur->bcn_sz; j < cur->y + cur->bcn_sz; j++) {
      if (j < 0 || j > (MAX_SZ - 1))
        goto cont;

      lines[j].line = realloc(lines[j].line, sizeof(Line*) * (lines[j].n + 1));
      lines[j].line[lines[j].n].start = cur->x - cur->bcn_sz + abs(skip);
      lines[j].line[lines[j].n].end   = cur->x + cur->bcn_sz - abs(skip);
      lines[j].n++;
cont:
      skip++;
    }
  }

  /* concat lines */
  for (i = 0; i < MAX_SZ; ++i) {
    real_lines[i].start = lines[i].line[0].start;
    real_lines[i].end = lines[i].line[0].end;
  }

  for (i = 0; i < MAX_SZ; ++i) {
    Full_line *cur = &lines[i];
    int j, x;
    for (x = 0; x < cur->n; ++x) {
      for (j = 0; j < cur->n; ++j) {
        if ((cur->line[j].start < real_lines[i].start)
            && (cur->line[j].end >= real_lines[i].start))
          real_lines[i].start = cur->line[j].start;
        if ((cur->line[j].end > real_lines[i].end)
            && (cur->line[j].start <= real_lines[i].end))
          real_lines[i].end = cur->line[j].end;
      }
    }
    if (real_lines[i].start < 0) real_lines[i].start = 0;
    if (real_lines[i].end > MAX_SZ - 1) real_lines[i].end = MAX_SZ - 1;
  }

  for (i = 0; i < MAX_SZ; ++i) {
    if (real_lines[i].start > 0 || real_lines[i].end < MAX_SZ - 1) {
      printf("p2: %ld\n", ((long)(real_lines[i].start == 0 ?
            real_lines[i].end + 1 : real_lines[i].start - 1)
            * (MAX_SZ - 1)) + i);
    }
  }

  for (i = 0; i < MAX_SZ; ++i)
    free(lines[i].line);

  free(lines);
  free(numbuf);
  free(in_orig);
  fclose(fp);
  return 0;
}
