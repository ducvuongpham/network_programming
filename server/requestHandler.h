#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/stat.h>

#include "dbHandler.h"
#define BUFFER_SZ 4096

void requestHandler(char *firstMessage, int sockfd);