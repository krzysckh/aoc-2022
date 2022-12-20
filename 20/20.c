#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <err.h>

typedef struct item_t {
  int v;
  int idx;
  int is_first;
  struct item_t *prev;
  struct item_t *next;
} item_t;

typedef struct {
  int     sz;
  item_t *it;
} arr_t;

item_t *getitem(arr_t *in, int idx) {
  int i;
  for (i = 0; i < in->sz; i++)
    if (in->it[i].idx == idx)
      return &in->it[i];

  err(1, "no idx %d", idx);
}

int getfirst(arr_t *in) {
  int i;
  for (i = 0; i < in->sz; i++)
    if (in->it[i].is_first)
      return i;

  err(1, "can't find first ???");
}

int getzero(arr_t *in) {
  int i;
  for (i = 0; i < in->sz; i++)
    if (in->it[i].v == 0)
      return i;

  err(1, "can't find zero"); 
}

void p1(arr_t *in, void *is_p2) {
  item_t *cur;
  int i,
      j,
      grove = 0;

  if (is_p2) {
    for (i = 0; i < in->sz; ++i) {
      in->it[i].v *= 811589153;
    }
  }

  for (i = 0; i < (is_p2 ? in->sz * 10 : in->sz); i++) {
    cur = getitem(in, i % in->sz);
    if (cur->v > 0) {
      for (j = 0; j < cur->v; j++) {
        if (cur->next->is_first) {
          cur->is_first = 1;
          cur->next->is_first = 0;
        } else if (cur->is_first) {
          cur->is_first = 0;
          cur->next->is_first = 1;
        }

        cur->prev->next = cur->next;
        cur->next->prev = cur->prev;

        cur->prev = cur->next;
        cur->next = cur->next->next;

        cur->prev->next = cur;
        cur->next->prev = cur;
      }
    } else {
      for (j = cur->v; j < 0; j++) {
        if (cur->is_first) {
          cur->is_first = 0;
          cur->next->is_first = 1;
        } else if (cur->prev->is_first) {
          cur->is_first = 1;
          cur->prev->is_first = 0;
        }

        cur->prev->next = cur->next;
        cur->next->prev = cur->prev;

        cur->next = cur->prev;
        cur->prev = cur->prev->prev;

        cur->prev->next = cur;
        cur->next->prev = cur;
      }
    }
  }

  cur = getitem(in, getzero(in));
  for (i = 1; i <= 3000; ++i) {
    cur = cur->next;
    if (i % 1000 == 0 || i % 2000 == 0 || i % 3000 == 0) {
      grove += cur->v;
    }
  }

  printf("%d\n", grove);
}

void p2(arr_t *in) {
  err(1, "fff");
  p1(in, (void*)0xdeadbeef);
}

int main (void) {
  FILE *fp = fopen("./in", "r");
  char *buf = malloc(128),
       *buf_orig;
  int   i;
  arr_t in = { .sz = 0, .it = NULL };

  if (!fp) err(1, "./in");

  buf_orig = buf;
  memset(buf, 0, 128);
  while ((*buf = fgetc(fp)) != EOF) {
    if (*buf == '\n') {
      buf = buf_orig;
      in.it = realloc(in.it, sizeof(item_t) * (in.sz + 1));
      in.it[in.sz].v = atoi(buf);
      in.it[in.sz].idx = in.sz;
      in.sz++;
      memset(buf, 0, 128);
    } else buf++;
  }

  for (i = 0; i < in.sz; ++i) {
    in.it[i].is_first = 0;
    if (i > 0)
      in.it[i].prev = &in.it[i - 1];
    else
      in.it[i].prev = &in.it[in.sz - 1];
    if (i + 1 < in.sz)
      in.it[i].next = &in.it[i + 1];
    else
      in.it[i].next = &in.it[0];
  }
  in.it[0].is_first = 1;

  p1(&in, NULL);
  p2(&in);

  free(in.it);
  free(buf_orig);
}
