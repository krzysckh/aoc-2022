#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <err.h>

typedef struct {
  char **pt;       /* the map */
  int maxh;        /* max h of a block */
  int h;           /* allocated height of the chamber */
} Chamber;

typedef enum {
  b_hplank,
  b_plus,
  b_l,
  b_vplank,
  b_square
} block_t;

#define block_n 5

typedef struct {
  block_t t;
  char **pt;
  int h;
} Block;

void draw(Chamber *c) {
  int i;
  for (i = c->h - 1; i >= 0; i--) {
    printf("|%s|\n", c->pt[i]);
  }
}

void initblocks(Block **b) {
  *b = malloc(sizeof(Block) * block_n);

  (*b)[0].t     = b_hplank;
  (*b)[0].pt    = malloc(sizeof(char*) * 1);
  (*b)[0].pt[0] = strdup("####");
  (*b)[0].h     = 1;

  (*b)[1].t     = b_plus;
  (*b)[1].pt    = malloc(sizeof(char*) * 3);
  (*b)[1].pt[0] = strdup(" # ");
  (*b)[1].pt[1] = strdup("###");
  (*b)[1].pt[2] = strdup(" # ");
  (*b)[1].h     = 3;

  (*b)[2].t     = b_l;
  (*b)[2].pt    = malloc(sizeof(char*) * 3);
  (*b)[2].pt[2] = strdup("  #");
  (*b)[2].pt[1] = strdup("  #");
  (*b)[2].pt[0] = strdup("###");
  (*b)[2].h     = 3;

  (*b)[3].t     = b_vplank;
  (*b)[3].pt    = malloc(sizeof(char*) * 4);
  (*b)[3].pt[0] = strdup("#");
  (*b)[3].pt[1] = strdup("#");
  (*b)[3].pt[2] = strdup("#");
  (*b)[3].pt[3] = strdup("#");
  (*b)[3].h     = 4;

  (*b)[4].t     = b_square;
  (*b)[4].pt    = malloc(sizeof(char*) * 2);
  (*b)[4].pt[0] = strdup("##");
  (*b)[4].pt[1] = strdup("##");
  (*b)[4].h     = 2;
}

void p1(char *in, void *is_p2) {
  char *list = in;
  int i,
      j,
      x,
      y;
  long long h = 0;
  block_t cur_block = 0;
  Block *blocks;
  Chamber c = { .pt = NULL, .maxh = 0, .h = 0 };

  initblocks(&blocks);

  for (long long rep = 0; rep < (is_p2 == NULL ? 2022 : 1000000000000); rep++) {
    /*if (rep % 1000000 == 0) printf("halo %lld/1000000 \n", rep/1000000);*/
    /* alloc more space in chamber if not enough */
    if (c.h < c.maxh + blocks[cur_block].h + 3) {
        c.pt = realloc(c.pt, sizeof(char*) * (c.h + blocks[cur_block].h + 3));
      for (i = c.h; i < c.h + blocks[cur_block].h + 3; i++)
        c.pt[i] = strdup("       \0");
      c.h += blocks[cur_block].h + 3;
    }

    /* update block */
    x = 2;
    y = c.maxh + 3;
    /*printf("%d\n", y);*/

    while (1) {
      int ok = 1;
      /* move r/l */
      int newx;
      if (*list == '>') {
        newx = x + 1;
      } else {
        newx = x - 1;
      }

      /* see if works with newx */
      if (newx >= 0) {
        for (i = 0; i < blocks[cur_block].h; ++i) {
          if (newx + (int)strlen(blocks[cur_block].pt[i]) > 7) ok = 0;
          for (j = 0; j < (int)strlen(blocks[cur_block].pt[i]); ++j)
            if (blocks[cur_block].pt[i][j] == '#')
              if (c.pt[y + i][j + newx] != ' ') ok = 0;
        }
      } else {
        ok = 0;
      }

      if (ok) x = newx;
      
      list++;
      if (*list != '<' && *list != '>') list = in; /* wrap list */

      if (y == 0) break;

      /* fall */
      ok = 1;
      for (i = 0; i < blocks[cur_block].h; ++i)
        for (j = 0; j < (int)strlen(blocks[cur_block].pt[i]); ++j)
          if (blocks[cur_block].pt[i][j] == '#')
            if (c.pt[y - 1 + i][j + x] != ' ') ok = 0;

      if (ok)
        y--;
      else
        break;
    }

    /* put block in place */
    for (i = blocks[cur_block].h - 1; i >= 0; --i)
      for (j = 0; j < (int)strlen(blocks[cur_block].pt[i]); ++j)
        if (blocks[cur_block].pt[i][j] == '#')
          c.pt[y + i][x + j] = '#';

    c.maxh = y + blocks[cur_block].h > c.maxh ? y + blocks[cur_block].h : c.maxh;

    cur_block = (1 + cur_block) % block_n;

    if (is_p2 != NULL) {
      if (c.h > 10000000) {
        char **top = malloc(sizeof(char*) * 10);
        for (i = 9; i >= 0; --i) {
          top[i] = strdup(c.pt[c.maxh - 10 + i]);
        }

        for (i = 0; i < c.h; i++)
          free(c.pt[i]);
        free(c.pt);

        c.pt = malloc(sizeof(char*) * 10);
        for (i = 0; i < 10; ++i)
          c.pt[i] = top[i];
        h += (h == 0) ? c.maxh : c.maxh - 10;
        c.maxh = c.h = 10;
        free(top);

        draw(&c);
      }
    }
  }
  if (is_p2 == NULL) {
    printf("p1: %d\n", c.maxh);
  } else {
    printf("p2: %lld\n", h);
  }

  /* free memory */
  for (i = 0; i < c.h; i++)
    free(c.pt[i]);
  free(c.pt);
  for (i = 0; i < block_n; ++i) {
    for (j = 0; j < blocks[i].h; j++)
      free(blocks[i].pt[j]);
    free(blocks[i].pt);
  }
  free(blocks);
}

void p2(char *in) {
  exit(1);
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
