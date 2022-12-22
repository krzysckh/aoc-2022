#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <err.h>

typedef enum {
  T_PLUS,
  T_MINUS,
  T_DIV,
  T_MUL
} op_type;

typedef struct operation_t {
  int has_value;
  int had_value;
  long value;

  char *l;
  char *r;
  op_type t;
} operation_t;

typedef struct monkey_t {
  char *name;
  operation_t op;
} monkey_t;

typedef struct Monkeys {
  monkey_t *m;
  int n;
} Monkeys;

static Monkeys monkeys = { .m = NULL, .n = 0 };

static monkey_t *get_by_name(const char *name) {
  int i;
  for (i = 0; i < monkeys.n; ++i) {
    if (strcmp(monkeys.m[i].name, name) == 0)
      return &monkeys.m[i];
  }

  err(1, "no monkey %s", name);
}

static long eval(monkey_t *monkey) {
  if (monkey->op.has_value)
    return monkey->op.value;
  monkey->op.value =
    monkey->op.t == T_PLUS ?
      eval(get_by_name(monkey->op.l)) + eval(get_by_name(monkey->op.r))
    : monkey->op.t == T_MINUS ?
      eval(get_by_name(monkey->op.l)) - eval(get_by_name(monkey->op.r))
    : monkey->op.t == T_DIV ?
      eval(get_by_name(monkey->op.l)) / eval(get_by_name(monkey->op.r))
    :
      eval(get_by_name(monkey->op.l)) * eval(get_by_name(monkey->op.r))
    ;

  monkey->op.has_value = 1;
  return monkey->op.value;
}

static void p1() {
  printf("p1: %ld\n", eval(get_by_name("root")));
}

static void update(Monkeys *m, const char *buf) {
  char *name = NULL,
       *op = NULL;
  int sz = 0;

  m->m = realloc(m->m, sizeof(monkey_t) * (m->n + 1));

  while (*buf) {
    if (*buf == ':') {
      name = malloc(sz + 1);
      strncpy(name, buf - sz, sz);
      name[sz] = 0;
      op = malloc(strlen(buf) + 1);
      strcpy(op, buf);
      op[strlen(buf)] = 0;
      break;
    } else sz++, buf++;
  }

  op += 2;
  if (isdigit(*op)) {
    m->m[m->n].op.has_value = 1;
    m->m[m->n].op.had_value = 1;
    m->m[m->n].op.value = atoi(op);

    m->m[m->n].op.l = NULL;
    m->m[m->n].op.r = NULL;
  } else {
    char *l = malloc(5),
         *r = malloc(5);
    strncpy(l, op, 4);
    strncpy(r, op + 7, 4);
    l[4] = r[4] = 0;

    m->m[m->n].op.l = l;
    m->m[m->n].op.r = r;
    switch (op[5]) {
      case '-': m->m[m->n].op.t = T_MINUS; break;
      case '+': m->m[m->n].op.t = T_PLUS;  break;
      case '*': m->m[m->n].op.t = T_MUL;   break;
      case '/': m->m[m->n].op.t = T_DIV;   break;
      default: err(1, "what");
    }

    m->m[m->n].op.has_value = 0;
    m->m[m->n].op.had_value = 0;
  }

  m->m[m->n].name = name;
  m->n++;

  free(op - 2);
  /* not freeing name */
}

int main (void) {
  FILE *fp = fopen("./in", "r");
  char *buf = malloc(128),
       *buf_orig = buf,
       *in;
  int sz,
      i;

  if (!fp) err(1, "./in");

  fseek(fp, 0, SEEK_END);
  sz = ftell(fp);
  fseek(fp, 0, SEEK_SET);

  in = malloc(sz + 1);
  fread(in, 1, sz, fp);
  in[sz] = 0;

  memset(buf, 0, 128);
  while (*in) {
    *buf++ = *in;
    if (*in == '\n') {
      buf = buf_orig;
      update(&monkeys, buf);

      memset(buf, 0, 128);
    }
    in++;
  }

  p1();

  for (i = 0; i < monkeys.n; ++i) {
    free(monkeys.m[i].name);
    if (!monkeys.m[i].op.has_value) {
      free(monkeys.m[i].op.l);
      free(monkeys.m[i].op.r);
    }
  }
  free(buf);
  free(in - sz);
}
