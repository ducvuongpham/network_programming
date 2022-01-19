var url = "http://test.com:5550/createfolder";

var xhr = new XMLHttpRequest();
xhr.open("POST", url);
xhr.setRequestHeader("Content-Type", "text/plain");
xhr.withCredentials = true;

xhr.onreadystatechange = function () {
  if (xhr.readyState === 4) {
    console.log(xhr.status);
    console.log(xhr.responseText);
  }
};

var data = `folderName: New Folder
motherID: 81cee4f93d`;

xhr.send(data);
