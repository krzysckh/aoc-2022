#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int isinarr(int *arr, int arrsz, int x) {
  int i;
  for (i = 0; i < arrsz; ++i)
    if (arr[i] == x)
      return 1;
  return 0;
}

void p(char *in, int pt) {
  int *n = malloc(sizeof(int) * 4),
      r = 0;
  char *buf = malloc(128),
       *buf_orig,
       *tok = malloc(5); 
  strcpy(tok, "-,-\n\0");

  while (*in) {
    buf_orig = buf;
    while (*tok) {
      while (*in != *tok)
        *buf++ = *in++;

      buf = buf_orig;
      *n++ = atoi(buf);
      memset(buf, 0, 128);
      tok++, in++;
    }
    tok -= 4, n -= 4;
    if (!pt) {
      if ((n[2] >= n[0] && n[3] <= n[1]) || (n[0] >= n[2] && n[1] <= n[3])) r++;
    } else {
      int *e1 = malloc((1 + n[1] - n[0]) * sizeof(int)),
          *e2 = malloc((1 + n[3] - n[2]) * sizeof(int)),
          i;

      for (i = n[0]; i <= n[1]; ++i) *e1++ = i;
      for (i = n[2]; i <= n[3]; ++i) *e2++ = i;
      e1 -= 1 + n[1] - n[0], e2 -= 1 + n[3] - n[2];

      for (i = 0; i < 1 + n[1] - n[0]; ++i) {
        if (isinarr(e2, 1 + n[3] - n[2], e1[i])) {
          r++;
          break;
        }
      }

      free(e1);
      free(e2);
    }
  }

  printf("p%d: %d\n", ++pt, r);

  free(tok);
  free(buf);
  free(n);
}

int main (void) {
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

  p(in, 0);
  p(in, 1);

  fclose(fp);
  free(in);

  return 0;
}

