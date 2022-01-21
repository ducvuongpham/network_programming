#include "requestHandler.h"
#include "responseHandler.h"

char *getValue(char *message, char *field, char *value, int max_size)
{
    char *mark = NULL;
    int i = 0;
    mark = strstr(message, field);
    if (mark != NULL)
    {
        mark = mark + strlen(field);
        while (mark[i] != '\n' && mark[i] != '\r' && mark[i] != '\0' && mark[i] != ';' && i < max_size)
        {
            value[i] = mark[i];
            i++;
        }
    }
    return value;
}

void signup(char *firstMessage, int sockfd)
{
    char firstName[25] = {'\0'};
    char lastName[25] = {'\0'};
    char email[50] = {'\0'};
    char username[50] = {'\0'};
    char password[50] = {'\0'};
    printf("%s\n", firstMessage);
    getValue(firstMessage, "firstName: ", firstName, sizeof(firstName));
    getValue(firstMessage, "lastName: ", lastName, sizeof(lastName));
    getValue(firstMessage, "email: ", email, sizeof(email));
    getValue(firstMessage, "username: ", username, sizeof(username));
    getValue(firstMessage, "password: ", password, sizeof(password));
    if (strstr(email, "@") == NULL)
    {
        res_signup(-3, sockfd);
        return;
    }

    printf("%s\n%s\n%s\n%s\n%s\n", firstName, lastName, email, username, password);
    // if (firstName && lastName && email && username && password)
    res_signup(db_signup(firstName, lastName, email, username, password), sockfd);
}

void signin(char *firstMessage, int sockfd)
{
    char username[50] = {'\0'};
    char password[50] = {'\0'};
    char uid[9] = {'\0'};
    int status = 0;
    getValue(firstMessage, "username: ", username, sizeof(username));
    getValue(firstMessage, "password: ", password, sizeof(password));

    // printf("%s\n%s\n", username, password);
    status = db_signin(username, password, uid);
    res_signin(status, uid, sockfd);
}

void upload(char *firstMessage, int sockfd)
{
    // printf("%s\n", firstMessage);

    char temp[514] = {'\0'};
    char filePath[512] = {'\0'};
    char uid[9] = {'\0'};
    char fileID[11] = {'\0'};
    char buff[BUFFER_SZ] = {'\0'};
    char *FileName;
    char *FolderID;
    char *path;
    int ContentLength = atoi(getValue(firstMessage, "Content-Length: ", temp, sizeof(temp)));
    // printf("%s\n", firstMessage);
    sscanf(firstMessage, "%s", temp);
    sscanf(firstMessage + strlen(temp) + 1, "%s", temp);
    strtok(temp, "/");
    FolderID = strtok(NULL, "/");
    FileName = strtok(NULL, "/");
    getValue(firstMessage, "uid=", uid, sizeof(uid));
    // printf("%s %s %s\n", FolderID, FileName, uid);
    if (FolderID == NULL || FileName == NULL || uid == NULL)
        return;
    if (strlen(uid) == 8 && strlen(FolderID) == 10 && strlen(FileName) != 0)
    {
        path = db_upload(FolderID, FileName, uid);
        if (path != NULL)
            strcpy(filePath, path);
        else
        {
            res_upload(-1, NULL, sockfd);
            return;
        }
    }
    else
    {
        res_upload(-1, NULL, sockfd);
        return;
    }

    strcpy(fileID, FolderID);
    sprintf(temp, "%s-t", filePath);

    FILE *fp = fopen(temp, "w+");
    char *data = strstr(firstMessage, "\r\n\r\n") + strlen("\r\n\r\n");
    if (data == NULL || data == (char *)0x8)
    {
        printf("SomeThing's wrong\n");
        return;
    }
    memset(buff, '\0', BUFFER_SZ);

    strcpy(buff, data);
    ContentLength -= strlen(buff);
    fwrite(buff, sizeof(char), strlen(buff), fp);

    res_upload(0, fileID, sockfd);

    memset(buff, '\0', BUFFER_SZ);
    int recv_bytes = 0;
    while (ContentLength > 0)
    {
        recv_bytes = recv(sockfd, buff, BUFFER_SZ, 0);
        if (recv_bytes <= 0)
            return;
        ContentLength -= recv_bytes;
        fwrite(buff, sizeof(char), strlen(buff), fp);
        memset(buff, '\0', BUFFER_SZ);
    }
    fclose(fp);

    sprintf(buff, "base64 -d %s > %s", temp, filePath);
    system(buff);
    sleep(1);
    sprintf(buff, "rm %s", temp);
    system(buff);
}

void download(char *firstMessage, int sockfd)
{
    char temp[514] = {'\0'};
    char fileName[512] = {'\0'};
    char uid[9] = {'\0'};
    char *fileID;
    sscanf(firstMessage, "%s", temp);
    sscanf(firstMessage + strlen(temp) + 1, "%s", temp);
    strtok(temp, "/");
    fileID = strtok(NULL, "/");
    getValue(firstMessage, "uid=", uid, sizeof(uid));
    strcpy(temp, db_download(fileID, fileName, uid));
    // printf("%s, %s\n", fileID);
    if (temp != NULL && fileName != NULL)
    {
        res_download(temp, fileName, sockfd);
    }
}

int creategroup(char *firstMessage, int sockfd)
{
    char groupName[51] = {'\0'};
    char uid[9] = {'\0'};
    char folderID[11] = {'\0'};
    char folderPath[512] = {'\0'};
    MYSQL_RES *result;
    getValue(firstMessage, "groupName: ", groupName, sizeof(groupName));
    getValue(firstMessage, "uid=", uid, sizeof(uid));
    if (strlen(uid) != 8 || strlen(groupName) > 50)
        return -1;
    // printf("%s \n%s\n", groupName, uid);
    result = db_create_group(groupName, uid);
    strcpy(folderID, res_create_group(result, sockfd));
    sprintf(folderPath, "%s/%s", storage_path, folderID);
    mkdir(folderPath, 0777);
    mysql_free_result(result);
    return 0;
}

int createfolder(char *firstMessage, int sockfd)
{
    char folderName[255] = {'\0'};
    char uid[9] = {'\0'};
    char folderID[11] = {'\0'};
    char *temp;
    MYSQL_RES *result;
    getValue(firstMessage, "folderName: ", folderName, sizeof(folderName));
    getValue(firstMessage, "uid=", uid, sizeof(uid));
    getValue(firstMessage, "motherID: ", folderID, sizeof(folderID));
    if (strlen(uid) != 8 || strlen(folderID) != 10)
    {
        res_create_folder(NULL, sockfd);
        return -1;
    }

    result = db_create_folder(folderName, folderID, uid);
    temp = res_create_folder(result, sockfd);
    // printf("%s %s %s %s\n", temp, folderName, folderID, uid);
    if (temp != NULL)
        mkdir(temp, 0777);
    mysql_free_result(result);
    return 0;
}

int getowngroups(char *firstMessage, int sockfd)
{
    char uid[9] = {'\0'};
    MYSQL_RES *result;
    getValue(firstMessage, "uid=", uid, sizeof(uid));
    if (strlen(uid) != 8)
    {
        res_create_folder(NULL, sockfd);
        return -1;
    }
    result = db_get_own_groups(uid);
    res_get_own_groups(result, sockfd);
    mysql_free_result(result);
    return 0;
}

int getjoingroups(char *firstMessage, int sockfd)
{
    char uid[9] = {'\0'};
    MYSQL_RES *result;
    getValue(firstMessage, "uid=", uid, sizeof(uid));
    if (strlen(uid) != 8)
    {
        res_create_folder(NULL, sockfd);
        return -1;
    }
    result = db_get_join_groups(uid);
    res_get_join_groups(result, sockfd);
    mysql_free_result(result);
    return 0;
}

int listfiles(char *firstMessage, int sockfd)
{
    char uid[9] = {'\0'};
    char folderID[11] = {'\0'};
    MYSQL_RES *result;
    getValue(firstMessage, "uid=", uid, sizeof(uid));
    getValue(firstMessage, "folderID: ", folderID, sizeof(folderID));

    if (strlen(uid) != 8 || strlen(folderID) != 10)
    {
        res_listfiles(NULL, sockfd);
        return -1;
    }
    result = db_listfiles(uid, folderID);
    res_listfiles(result, sockfd);
    mysql_free_result(result);
    return 0;
}

int joingroup(char *firstMessage, int sockfd)
{
    char uid[9] = {'\0'};
    char groupID[6] = {'\0'};
    MYSQL_RES *result;
    getValue(firstMessage, "uid=", uid, sizeof(uid));
    getValue(firstMessage, "groupID: ", groupID, sizeof(groupID));

    if (strlen(uid) != 8 || strlen(groupID) != 5)
    {
        res_join_group(NULL, sockfd);
        return -1;
    }
    result = db_join_group(uid, groupID);
    res_join_group(result, sockfd);
    mysql_free_result(result);
    return 0;
}

void requestHandler(char *firstMessage, int sockfd)
{
    char command[100];
    sscanf(firstMessage, "%s", command);
    // printf("%s\n", firstMessage);

    if (strcasecmp(command, "GET") == 0)
    {
        sscanf(firstMessage + strlen(command) + 1, "%s", command);
        if (strstr(command, "/download") == command)
            download(firstMessage, sockfd);
    }

    if (strcasecmp(command, "POST") == 0)
    {
        sscanf(firstMessage + strlen(command) + 1, "%s", command);
        if (strstr(command, "/signup") == command)
            signup(firstMessage, sockfd);
        if (strstr(command, "/signin") == command)
            signin(firstMessage, sockfd);
        if (strstr(command, "/upload") == command)
            upload(firstMessage, sockfd);
        if (strstr(command, "/creategroup") == command)
            creategroup(firstMessage, sockfd);
        if (strstr(command, "/createfolder") == command)
            createfolder(firstMessage, sockfd);
        if (strstr(command, "/getownedgroups") == command)
            getowngroups(firstMessage, sockfd);
        if (strstr(command, "/getjoinedgroups") == command)
            getjoingroups(firstMessage, sockfd);
        if (strstr(command, "/listfiles") == command)
            listfiles(firstMessage, sockfd);
        if (strstr(command, "/joingroup") == command)
            joingroup(firstMessage, sockfd);
    }
}