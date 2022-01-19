#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/socket.h>
#include <mysql/mysql.h>

#include "config.h"
#define DOWNLOAD_RESPONSE_HEADER                 \
    "HTTP/1.1 200 OK\r\n"                        \
    "Content-Type: application/octet-stream\r\n" \
    "Content-Disposition: attachment; "

#define STATUS_OK_RESPONSE_HEADER                    \
    "HTTP/1.1 200 OK\r\n"                            \
    "Content-Type: application/json\r\n"             \
    "Access-Control-Allow-Origin: " domain           \
    "\r\nAccess-Control-Allow-Credentials: true\r\n" \
    "Content-Length: "

#define STATUS_KO_RESPONSE_HEADER                    \
    "HTTP/1.1 400 Bad Request\r\n"                   \
    "Content-Type: application/json\r\n"             \
    "Access-Control-Allow-Origin: " domain           \
    "\r\nAccess-Control-Allow-Credentials: true\r\n" \
    "Content-Length: "

int res_download(char *filePath, char *fileName, int sockfd);
int res_upload(int status, char *fileID, int sockfd);
int res_signup(int status, int sockfd);
int res_signin(int status, char *uid, int sockfd);
char *res_create_group(MYSQL_RES *result, int sockfd);
char *res_create_folder(MYSQL_RES *result, int sockfd);
int res_get_own_groups(MYSQL_RES *result, int sockfd);
int res_get_join_groups(MYSQL_RES *result, int sockfd);
int res_listfiles(MYSQL_RES *result, int sockfd);
int res_join_group(MYSQL_RES *result, int sockfd);
