var url = "http://test.com:5550/signup";

var xhr = new XMLHttpRequest();
xhr.open("POST", url);
xhr.setRequestHeader("Content-Type", "text/plain");

xhr.onreadystatechange = function () {
  if (xhr.readyState === 4) {
    console.log(xhr.status);
    console.log(xhr.responseText);
  }
};

var data = `firstName: Pham Duc
lastName: Vuong
email: ducvuongpham@gmail.com
username: ducvuongpham
password: 123456`;

xhr.send(data);
