/********************************************************************
 * File: instrument.c
 *
 * Instrumentation source -- link this with your application, and
 *  then execute to build trace data file (trace.txt).
 *
 * Author: M. Tim Jones <mtj@mtjones.com>
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdint.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <string.h>
#include <errno.h>
#include <sys/ipc.h>
#include <sys/shm.h>

static FILE *fp = NULL;
char *p_off = NULL;

/* Function prototypes with attributes */

void main_constructor(void)
    __attribute__((no_instrument_function, constructor));

void __cyg_profile_func_enter(void *, void *)
    __attribute__((no_instrument_function));

void __cyg_profile_func_exit(void *, void *)
    __attribute__((no_instrument_function));

void main_constructor(void) {

  int shmid = shmget(0x881126, 1, IPC_CREAT | 0600);
  fprintf(stderr, "debug ..shmget shmid=%d\n", shmid);

  p_off = shmat(shmid, NULL, 0);
  if ((void *)- 1 == p_off) {
    fprintf(stderr, "shmat failed.%s\n", strerror(errno));
    exit(-1);
  }
}

void __cyg_profile_func_enter(void *this, void *callsite) {
  static int prev_off = 1;
  static int suffix = 0;

  if ((1 == prev_off && 0 == *p_off) || NULL == fp) {
    ++suffix;
    if (NULL != fp) {
      fclose(fp);
    }

    char fname[100];
    snprintf(fname, sizeof(fname), "trace.txt.%d", suffix);
    fp = fopen(fname, "w");
  }

  prev_off = *p_off;
  if (*p_off)
    return;

  //fprintf(fp, "F%p\n", (int *)callsite);
  fprintf(fp, "E%p\n", (int *)this);
}

void __cyg_profile_func_exit(void *this, void *callsite) {
  if (*p_off)
    return;
  fprintf(fp, "X%p\n", (int *)this);
}
