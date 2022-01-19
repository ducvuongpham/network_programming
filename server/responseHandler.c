#include "responseHandler.h"
int res_download(char *filePath, char *fileName, int sockfd)
{
    char header[BUFSIZ] = {'\0'};
    int read_bytes = 0;
    char buff[BUFSIZ] = {'\0'};

    int ContentLength = 0;
    FILE *fp = fopen(filePath, "r");
    if (fp == NULL)
    {
        printf("File not exist");
        return -1;
    }
    fseek(fp, 0L, SEEK_END);
    ContentLength = ftell(fp);
    rewind(fp);

    sprintf(header, "%s filename=\"%s\"\r\nContent-Length: %d\r\n\r\n", DOWNLOAD_RESPONSE_HEADER, fileName, ContentLength);

    send(sockfd, header, strlen(header), 0);
    while (ContentLength > 0)
    {
        read_bytes = fread(buff, sizeof(char), sizeof(buff), fp);
        send(sockfd, buff, read_bytes, 0);
        if (read_bytes <= 0)
        {
            fclose(fp);
            return -1;
        }
        ContentLength = ContentLength - read_bytes;
        // printf("%d %d\n", ContentLength, read_bytes);
    }
    fclose(fp);
    return 0;
}

int res_signup(int status, int sockfd)
{
    char message[BUFSIZ] = {'\0'};
    char body[BUFSIZ / 2] = {'\0'};
    switch (status)
    {
    case 0:
        strcpy(body, "{\"success\":\"true\"}");
        sprintf(message, "%s%ld\r\n\r\n%s", STATUS_OK_RESPONSE_HEADER, strlen(body), body);
        break;
    case -1:
        strcpy(body, "{\"error\":\"email\"}");
        break;
    case -2:
        strcpy(body, "{\"error\":\"username\"}");
        break;
    case -3:
        strcpy(body, "{\"error\":\"email and username\"}");
        break;
    default:
        break;
    }
    if (status != 0)
        sprintf(message, "%s%ld\r\n\r\n%s", STATUS_KO_RESPONSE_HEADER, strlen(body), body);
    send(sockfd, message, strlen(message), 0);
    return 0;
}

int res_signin(int status, char *uid, int sockfd)
{
    char message[BUFSIZ] = {'\0'};
    char body[BUFSIZ / 2] = {'\0'};
    // printf("%s %d\n", uid, status);
    switch (status)
    {
    case 0:
        sprintf(body, "{\"success\":\"true\"}");
        // sprintf(message, "%s%ld\r\n\r\n%s", STATUS_OK_RESPONSE_HEADER, strlen(body), body);
        sprintf(message, "%s%ld\r\n%s%s; HttpOnly; \r\n\r\n%s", STATUS_OK_RESPONSE_HEADER, strlen(body), "Set-Cookie: uid=", uid, body);

        // printf("%s\n", message);
        break;
    case -1:
        strcpy(body, "{\"error\":\"wrong password\"}");
        break;
    case -2:
        strcpy(body, "{\"error\":\"user not exist\"}");
        break;
    default:
        break;
    }
    if (status != 0)
        sprintf(message, "%s%ld\r\n\r\n%s", STATUS_KO_RESPONSE_HEADER, strlen(body), body);
    send(sockfd, message, strlen(message), 0);
    return 0;
}

int res_upload(int status, char *fileID, int sockfd)
{
    char message[BUFSIZ] = {'\0'};
    char body[BUFSIZ / 2] = {'\0'};
    switch (status)
    {
    case 0:
        sprintf(body, "{\"fileID\":\"%s\"}", fileID);
        sprintf(message, "%s%ld\r\n\r\n%s", STATUS_OK_RESPONSE_HEADER, strlen(body), body);
        break;
    default:
        break;
    }
    if (status != 0)
        sprintf(message, "%s%ld\r\n\r\n%s", STATUS_KO_RESPONSE_HEADER, strlen(body), body);
    send(sockfd, message, strlen(message), 0);
    return 0;
}

char *res_create_group(MYSQL_RES *result, int sockfd)
{
    char message[BUFSIZ] = {'\0'};
    char body[BUFSIZ / 2] = {'\0'};
    MYSQL_ROW row;
    if (result != NULL)
        row = mysql_fetch_row(result);
    else
    {
        sprintf(message, "%s\r\n\r\n", STATUS_KO_RESPONSE_HEADER);
        send(sockfd, message, strlen(message), 0);
        return NULL;
    }
    if (strlen(row[0]) != 0 && strlen(row[1]) != 0)
    {
        sprintf(body, "{\"group_id\":\"%s\",\"group_folder_id\":\"%s\"}", row[0], row[1]);
        sprintf(message, "%s%ld\r\n\r\n%s", STATUS_OK_RESPONSE_HEADER, strlen(body), body);
    }
    else
    {
        sprintf(message, "%s\r\n\r\n", STATUS_KO_RESPONSE_HEADER);
    }
    send(sockfd, message, strlen(message), 0);
    return row[1];
}

char *res_create_folder(MYSQL_RES *result, int sockfd)
{
    char message[BUFSIZ] = {'\0'};
    char body[BUFSIZ / 2] = {'\0'};
    char fileID[11] = {'\0'};
    MYSQL_ROW row = NULL;
    if (result != NULL)
        row = mysql_fetch_row(result);
    else
    {
        sprintf(message, "%s\r\n\r\n", STATUS_KO_RESPONSE_HEADER);
        send(sockfd, message, strlen(message), 0);
        return NULL;
    }
    if (row[0] != NULL)
    {
        // strcpy(filePath, row[0]);
        strcpy(fileID, row[0] + strlen(row[0]) - 10);
        sprintf(body, "{\"folder_id\":\"%s\"}", fileID);
        // printf("%s %s\n", body, fileID);
        sprintf(message, "%s%ld\r\n\r\n%s", STATUS_OK_RESPONSE_HEADER, strlen(body), body);
        send(sockfd, message, strlen(message), 0);
        return row[0];
    }
    else
    {
        sprintf(message, "%s\r\n\r\n", STATUS_KO_RESPONSE_HEADER);
        send(sockfd, message, strlen(message), 0);
        return NULL;
    }
}

int res_get_own_groups(MYSQL_RES *result, int sockfd)
{
    char *message;
    MYSQL_ROW row = NULL;
    if (result != NULL)
        row = mysql_fetch_row(result);
    else
    {
        message = malloc(sizeof(char) * strlen(STATUS_KO_RESPONSE_HEADER) + 15);
        sprintf(message, "%s\r\n\r\n", STATUS_KO_RESPONSE_HEADER);
        send(sockfd, message, strlen(message), 0);
        free(message);
        return -1;
    }
    if (row[0] != NULL)
    {
        message = malloc(sizeof(char) * (strlen(row[0]) + strlen(STATUS_OK_RESPONSE_HEADER) + 15));
        sprintf(message, "%s%ld\r\n\r\n%s", STATUS_OK_RESPONSE_HEADER, strlen(row[0]), row[0]);
    }
    else
    {
        message = malloc(sizeof(char) * strlen(STATUS_KO_RESPONSE_HEADER) + 15);
        sprintf(message, "%s\r\n\r\n", STATUS_KO_RESPONSE_HEADER);
    }
    send(sockfd, message, strlen(message), 0);
    free(message);
    return 0;
}

int res_get_join_groups(MYSQL_RES *result, int sockfd)
{
    char *message;
    MYSQL_ROW row = NULL;
    if (result != NULL)
        row = mysql_fetch_row(result);
    else
    {
        message = malloc(sizeof(char) * strlen(STATUS_KO_RESPONSE_HEADER) + 15);
        sprintf(message, "%s\r\n\r\n", STATUS_KO_RESPONSE_HEADER);
        send(sockfd, message, strlen(message), 0);
        free(message);
        return -1;
    }
    if (row[0] != NULL)
    {
        message = malloc(sizeof(char) * (strlen(row[0]) + strlen(STATUS_OK_RESPONSE_HEADER) + 15));
        sprintf(message, "%s%ld\r\n\r\n%s", STATUS_OK_RESPONSE_HEADER, strlen(row[0]), row[0]);
    }
    else
    {
        message = malloc(sizeof(char) * strlen(STATUS_KO_RESPONSE_HEADER) + 15);
        sprintf(message, "%s\r\n\r\n", STATUS_KO_RESPONSE_HEADER);
    }
    send(sockfd, message, strlen(message), 0);
    free(message);
    return 0;
}

int res_listfiles(MYSQL_RES *result, int sockfd)
{
    char *message;
    MYSQL_ROW row = NULL;
    if (result != NULL)
        row = mysql_fetch_row(result);
    else
    {
        message = malloc(sizeof(char) * strlen(STATUS_OK_RESPONSE_HEADER) + 15);
        sprintf(message, "%s\r\n\r\n", STATUS_OK_RESPONSE_HEADER);
        send(sockfd, message, strlen(message), 0);
        free(message);
        return -1;
    }
    if (row[0] != NULL)
    {
        message = malloc(sizeof(char) * (strlen(row[0]) + strlen(STATUS_OK_RESPONSE_HEADER) + 15));
        sprintf(message, "%s%ld\r\n\r\n%s", STATUS_OK_RESPONSE_HEADER, strlen(row[0]), row[0]);
    }
    else
    {
        message = malloc(sizeof(char) * strlen(STATUS_OK_RESPONSE_HEADER) + 15);
        sprintf(message, "%s\r\n\r\n", STATUS_OK_RESPONSE_HEADER);
    }
    send(sockfd, message, strlen(message), 0);
    free(message);
    return 0;
}

int res_join_group(MYSQL_RES *result, int sockfd)
{
    char *message;
    MYSQL_ROW row = NULL;
    if (result != NULL)
        row = mysql_fetch_row(result);
    else
    {
        message = malloc(sizeof(char) * strlen(STATUS_OK_RESPONSE_HEADER) + 15);
        sprintf(message, "%s\r\n\r\n", STATUS_OK_RESPONSE_HEADER);
        send(sockfd, message, strlen(message), 0);
        free(message);
        return -1;
    }
    if (row[0] != NULL)
    {
        message = malloc(sizeof(char) * (strlen(row[0]) + strlen(STATUS_OK_RESPONSE_HEADER) + 15));
        sprintf(message, "%s%ld\r\n\r\n%s", STATUS_OK_RESPONSE_HEADER, strlen(row[0]), row[0]);
    }
    else
    {
        message = malloc(sizeof(char) * strlen(STATUS_OK_RESPONSE_HEADER) + 15);
        sprintf(message, "%s\r\n\r\n", STATUS_OK_RESPONSE_HEADER);
    }
    send(sockfd, message, strlen(message), 0);
    free(message);
    return 0;
}