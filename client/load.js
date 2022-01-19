const domain = "http://test.com:5550/"
const fe_domain = "http://test.com:5500/"

function request(command, data) {
    var url = domain + command;

    this.xhr = new XMLHttpRequest();
    this.xhr.open("POST", url);
    this.xhr.setRequestHeader("Content-Type", "text/plain");
    this.xhr.withCredentials = true;
}

function add_group(id, gid, gfid, gname) {
    let groups = document.querySelector("#" + id);
    groups.innerHTML += ('<div class="w3-bar-item w3-medium" onclick="show_group(id)" gid=' + gid + ' id=' + gfid + '> ' + gname + '</div> ')
}

function show_group(gfid) {
    var title = document.querySelector("#main > ul > li.file-sub-active.show-up");
    title.parentElement.classList.add("active-folder-wrapper")
    while (title.nextElementSibling != null)
        title.nextElementSibling.remove();
    listfiles(gfid);
    title.id = gfid;
    title.innerHTML = '<b class="tooltip">' + document.getElementById(gfid).innerText + '<span class="tooltiptext">ID:' + document.getElementById(gfid).getAttribute("gid") + '</span></b >'
    title.style.display = 'block'
    document.getElementsByClassName("address-search-input")[0].value = '';
    let pathbar = document.getElementsByClassName("address-short-btn")[0]
    while (pathbar.firstChild != null) {
        pathbar.firstChild.remove();
    }
}

function load_groups(id) {
    let groups = document.querySelector("#" + id);
    var newRequest = new request("get" + id);
    newRequest.xhr.onreadystatechange = function () {
        if (newRequest.xhr.readyState === 4) {
            if (newRequest.xhr.status == 200) {
                let result = JSON.parse(newRequest.xhr.responseText);
                result.forEach(element => {
                    add_group(id, element.gid, element.id, element.name)
                });
            }
        }
    };
    newRequest.xhr.send();
}
