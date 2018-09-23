
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

int main(int argc, char *argv[]) {
  if(argc!=2)
  {
    fprintf(stderr, "Usage: %s [0|1]\n", argv[0]);
	return -1;
  }


  int val = !!atoi(argv[1]);

  int shmid = shmget(0x881126, 1, 0600);
  if (-1 == shmid) {
    fprintf(stderr, "shmget failed.%s\n", strerror(errno));
    return -1;
  }


  char *p_off = shmat(shmid, NULL, 0);
  if ((char *)- 1 == p_off) {
    fprintf(stderr, "shmat failed.%s\n", strerror(errno));
    return -1;
  }

  printf("off value:from %d to %d\n", *p_off, val);
  *p_off = val;
  return 0;
}
