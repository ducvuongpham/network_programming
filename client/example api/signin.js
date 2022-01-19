var url = "http://test.com:5550/signin";

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

var data = `username: ducvuongpham@gmail.com
password: 123456`;

xhr.send(data);
