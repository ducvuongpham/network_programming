var url = "http://test.com:5550/upload/2e42f7fc14";
const file = document.getElementById("image-file").files[0];
var uid;
var xhr = new XMLHttpRequest();
url = url + "/" + file.name;
xhr.open("POST", url);

xhr.setRequestHeader("Content-Type", "text/plain");
xhr.withCredentials = true;
xhr.onreadystatechange = function () {
  if (xhr.readyState === 4) {
    console.log(xhr.status);
    console.log(xhr.responseText);
  }
};

var data;
if (file) {
  const reader = new FileReader();
  reader.onload = function (evt) {
    // const metadata = `name: ${file.name}, type: ${file.type}, size: ${file.size}, contents:`;
    let contents = evt.target.result;
    let cut = contents.indexOf(";base64,"); // cut the "data:video/mp4;base64," part
    contents = contents.slice(cut + ";base64,".length);
    xhr.send(contents);
    //console.log(contents);
  };
  reader.readAsDataURL(file);
}
