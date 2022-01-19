#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <mysql/mysql.h>
#include "config.h"
#define BUFFER_SZ 4096

int db_signup(char *firstName, char *lastName, char *email, char *username, char *password);
int db_signin(char *email, char *password, char *uid);
char *db_upload(char *folderID, char *filename, char *uid);
char *db_download(char *fileID, char *fileName, char *uid);
MYSQL_RES *db_create_group(char *groupName, char *uid);
MYSQL_RES *db_create_folder(char *folderName, char *motherID, char *uid);
MYSQL_RES *db_get_own_groups(char *uid);
MYSQL_RES *db_get_join_groups(char *uid);
MYSQL_RES *db_listfiles(char *uid, char *folderID);
MYSQL_RES *db_join_group(char *uid, char *groupID);
