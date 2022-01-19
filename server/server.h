#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <pthread.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include "requestHandler.h"

#define MAX_CLIENTS 5

static unsigned int cli_count = 0;
static int sessionID = 10;

/* Client structure */
typedef struct
{
    struct sockaddr_in address;
    int sockfd;
    int sessionID;
    char uid[9];
    char check[40];
} client_t;

client_t *clients[MAX_CLIENTS];

pthread_mutex_t clients_mutex = PTHREAD_MUTEX_INITIALIZER;