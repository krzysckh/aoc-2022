#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int strrpt(char *s, char c) {
  int ret = 0;
  while (*s)
    if (*s++ == c)
      ++ret;

  return ret;
}

int *p1(char *in, int print) {
  int max = 0,
      cur = 0,
      *ret = malloc(sizeof(int) * (1 + strrpt(in, '\n'))),
      n = 0;
  char *nbuf = malloc(512),
       *nbuf_orig;

  nbuf_orig = nbuf;
  while (*in) {
    if (*in == '\n') {
      max = cur > max ? cur : max;
      ret[n++] = cur;
      cur = 0;
    } else {
      while (isspace(*in)) in++;
      nbuf = nbuf_orig;
      memset(nbuf, 0, 512);

      while (*in && *in != '\n')
        *nbuf++ = *in++;

      cur += atoi(nbuf_orig);
    }
    in++;
  }

  if (print)
    printf("p1: %d\n", max);

  free(nbuf_orig);

  ret[n] = -1;
  return ret;
}

int cmp(const void* x, const void* y) {
  return (*(int*)x - *(int*)y);
}

void p2(char *in) {
  int *all = p1(in, 0),
      cnt = 0;
  while (all[cnt++] != -1)
    ;
  --cnt;

  qsort(all, cnt, sizeof(int), cmp);

  printf("p2: %d\n", all[cnt-1] + all[cnt-2] + all[cnt-3]);
  free(all);
}

int main(void) {
  FILE *fp = fopen("./in", "r");
  char *in;
  int sz;
  if (!fp) exit(1);

  fseek(fp, 0, SEEK_END);
  sz = ftell(fp);
  fseek(fp, 0, SEEK_SET);
  in = malloc(sz + 1);

  fread(in, 1, sz, fp);
  in[sz] = 0;

  /* lmao */
  free(p1(in, 1));
  p2(in);

  fclose(fp);
  free(in);
  return 0;
}
