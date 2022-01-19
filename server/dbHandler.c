#include "dbHandler.h"
void finish_with_error(MYSQL *con)
{
    fprintf(stderr, "%s\n", mysql_error(con));
    mysql_close(con);
    // exit(1);
}

MYSQL *db_create_con()
{
    MYSQL *con;
    con = mysql_init(NULL);
    if (con == NULL)
    {
        fprintf(stderr, "mysql_init() failed\n");
        exit(-1);
    }
    if (mysql_real_connect(con, db_ip, db_user, db_passwd, db_name, 0, NULL, 0) == NULL)
    {
        finish_with_error(con);
    }
    return con;
}

/*  Return 0 if success. If duplicate, return -1 for email, -2 for username and -3 for both*/
int db_signup(char *firstName, char *lastName, char *email, char *username, char *password)
{
    MYSQL *con = db_create_con();
    char query[BUFFER_SZ] = {'\0'};
    sprintf(query, "SELECT signup('%s', '%s', '%s', '%s', '%s');", firstName, lastName, email, username, password);

    if (mysql_query(con, query))
    {
        finish_with_error(con);
    }
    MYSQL_RES *result = mysql_store_result(con);
    if (result == NULL)
    {
        finish_with_error(con);
    }
    mysql_close(con);
    MYSQL_ROW row = mysql_fetch_row(result);
    int return_value = atoi(row[0]);
    mysql_free_result(result);
    return return_value;
}

/*  Return 0 if success, -1 if wrong pass, -2 if user not exist*/
int db_signin(char *email, char *password, char *uid)
{
    MYSQL *con = db_create_con();
    char query[BUFFER_SZ] = {'\0'};
    sprintf(query, "SELECT signin('%s', '%s');", email, password);

    if (mysql_query(con, query))
    {
        finish_with_error(con);
    }
    MYSQL_RES *result = mysql_store_result(con);
    if (result == NULL)
    {
        finish_with_error(con);
    }
    mysql_close(con);
    MYSQL_ROW row = mysql_fetch_row(result);
    int return_value;
    if (strcmp(row[0], "-1") == 0 || strcmp(row[0], "-2") == 0)
    {
        return_value = atoi(row[0]);
        mysql_free_result(result);
        return return_value;
    }
    else
    {
        strcpy(uid, row[0]);
        mysql_free_result(result);
        return 0;
    }
}

char *db_upload(char *folderID, char *filename, char *uid)
{
    MYSQL *con = db_create_con();
    char query[BUFFER_SZ] = {'\0'};
    sprintf(query, "SELECT createFIle('%s', '%s', '%s');", filename, folderID, uid);

    if (mysql_query(con, query))
    {
        finish_with_error(con);
    }
    MYSQL_RES *result = mysql_store_result(con);
    if (result == NULL)
    {
        finish_with_error(con);
    }
    MYSQL_ROW row = mysql_fetch_row(result);
    strcpy(folderID, row[0]);
    mysql_free_result(result);
    sprintf(query, "SELECT getPath('%s', '%s', '%s');", folderID, uid, storage_path);

    if (mysql_query(con, query))
    {
        finish_with_error(con);
    }
    result = mysql_store_result(con);
    if (result == NULL)
    {
        finish_with_error(con);
    }
    row = mysql_fetch_row(result);
    strcpy(filename, row[0]);
    mysql_free_result(result);

    mysql_close(con);
    return filename;
}

char *db_download(char *fileID, char *fileName, char *uid)
{
    MYSQL *con = db_create_con();
    char query[BUFFER_SZ] = {'\0'};

    sprintf(query, "SELECT fname FROM files WHERE fid = '%s'", fileID);

    if (mysql_query(con, query))
    {
        finish_with_error(con);
    }
    MYSQL_RES *result = mysql_store_result(con);
    if (result == NULL)
    {
        finish_with_error(con);
    }
    MYSQL_ROW row = mysql_fetch_row(result);
    strcpy(fileName, row[0]);
    mysql_free_result(result);

    sprintf(query, "SELECT getPath('%s', '%s', '%s');", fileID, uid, storage_path);

    if (mysql_query(con, query))
    {
        finish_with_error(con);
    }
    result = mysql_store_result(con);
    if (result == NULL)
    {
        finish_with_error(con);
    }
    row = mysql_fetch_row(result);

    mysql_close(con);
    mysql_free_result(result);
    return row[0];
}

MYSQL_RES *db_create_group(char *groupName, char *uid)
{
    MYSQL *con = db_create_con();
    char query[BUFFER_SZ] = {'\0'};
    sprintf(query, "CALL createGroup('%s', '%s');", groupName, uid);
    // printf("%s \n", query);
    if (mysql_query(con, query))
    {
        finish_with_error(con);
    }
    MYSQL_RES *result = mysql_store_result(con);
    if (result == NULL)
    {
        finish_with_error(con);
    }

    mysql_close(con);
    return result;
}

MYSQL_RES *db_create_folder(char *folderName, char *motherID, char *uid)
{
    MYSQL *con = db_create_con();
    char query[BUFFER_SZ] = {'\0'};
    sprintf(query, "SELECT createFolder('%s', '%s', '%s', '%s');", folderName, motherID, uid, storage_path);

    if (mysql_query(con, query))
    {
        finish_with_error(con);
    }
    MYSQL_RES *result = mysql_store_result(con);
    if (result == NULL)
    {
        finish_with_error(con);
    }

    mysql_close(con);
    return result;
}

MYSQL_RES *db_get_own_groups(char *uid)
{
    MYSQL *con = db_create_con();
    char query[BUFFER_SZ] = {'\0'};
    sprintf(query, "SELECT JSON_ARRAYAGG(JSON_OBJECT('gid', `gid`, 'id', `gFolderID`, 'name', `gname`)) from `groups` WHERE getPermision(`gFolderID`,'%s') = 2;", uid);
    if (mysql_query(con, query))
    {
        finish_with_error(con);
    }
    MYSQL_RES *result = mysql_store_result(con);
    if (result == NULL)
    {
        finish_with_error(con);
    }

    mysql_close(con);
    return result;
}

MYSQL_RES *db_get_join_groups(char *uid)
{
    MYSQL *con = db_create_con();
    char query[BUFFER_SZ] = {'\0'};
    sprintf(query, "SELECT JSON_ARRAYAGG(JSON_OBJECT('gid', `gid`, 'id', `gFolderID`, 'name', `gname`)) from `groups` WHERE getPermision(`gFolderID`,'%s') = 1;", uid);
    if (mysql_query(con, query))
    {
        finish_with_error(con);
    }
    MYSQL_RES *result = mysql_store_result(con);
    if (result == NULL)
    {
        finish_with_error(con);
    }

    mysql_close(con);
    return result;
}

MYSQL_RES *db_listfiles(char *uid, char *folderID)
{
    MYSQL *con = db_create_con();
    char query[BUFFER_SZ] = {'\0'};
    sprintf(query, "SELECT JSON_ARRAYAGG(JSON_OBJECT('id', `fid`, 'name', `fname`, 'type', `fType`)) from `files` WHERE (motherFolder = '%s' AND getPermision(`fid`,'%s') > 0);", folderID, uid);
    if (mysql_query(con, query))
    {
        finish_with_error(con);
    }
    MYSQL_RES *result = mysql_store_result(con);
    if (result == NULL)
    {
        finish_with_error(con);
    }

    mysql_close(con);
    return result;
}

MYSQL_RES *db_join_group(char *uid, char *groupID)
{
    MYSQL *con = db_create_con();
    char query[BUFFER_SZ] = {'\0'};
    sprintf(query, "SELECT COUNT(*) FROM userInGroup WHERE uid = '%s' AND gid = '%s';", uid, groupID);
    if (mysql_query(con, query))
    {
        finish_with_error(con);
    }
    MYSQL_RES *result = mysql_store_result(con);
    if (result == NULL)
    {
        finish_with_error(con);
        return NULL;
    }
    MYSQL_ROW row = mysql_fetch_row(result);
    if (atoi(row[0]) != 0)
    {
        mysql_free_result(result);
        mysql_close(con);
        return NULL;
    }
    mysql_free_result(result);

    sprintf(query, "INSERT INTO `userInGroup` (`gid`, `uid`) VALUES ('%s', '%s');", groupID, uid);
    if (mysql_query(con, query))
    {
        finish_with_error(con);
    }
    sprintf(query, "SELECT JSON_OBJECT('gid', groups.gid, 'id', `gFolderID`, 'name', `gname`) from `groups`, `userInGroup` WHERE groups.gid = '%s' AND groups.gid = userInGroup.gid AND userInGroup.uid = '%s';", groupID, uid);
    if (mysql_query(con, query))
    {
        finish_with_error(con);
    }
    result = mysql_store_result(con);

    mysql_close(con);
    return result;
}