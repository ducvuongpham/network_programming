

/*----------Folder And Files Icons---------------|START---------*/
$('.big-file-manager.theme-structure ul > li > b').contents().filter(function () {
  return this.nodeType == 3 && $.trim(this.textContent) != '';
}).wrap('<span autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false" contenteditable="false" class="name" />');
function filesAndFolderIcons(newData) {
  function letGoSmallA(a) {
    var getType = $(a).attr('data-file-icon');
    if (getType == "folder") {
      $(a).children('b').prepend('<i class="fas fa-folder"></i>');
    } else if (getType == "html" || getType == "css" || getType == "js" || getType == "php") {
      $(a).children('b').prepend('<i class="fas fa-file aaaaa"></i>');
    } else if (getType == "layout") {
      $(a).children('b').prepend('<i class="fas fa-th-large"></i>');
    } else if (getType == "image") {
      $(a).children('b').prepend('<i class="far fa-images"></i>');
    } else if (getType == "video") {
      $(a).children('b').prepend('<i class="fas fa-video"></i>');
    }
  }
  if (newData == "newData") {
    $('[data-new="new"][data-file-icon]').each(function () {
      letGoSmallA(this);
    });
  } else {
    $('[data-file-icon]').each(function () {
      letGoSmallA(this);
    });
  }
}
filesAndFolderIcons();
/*----------Folder And Files Icons---------------|END-------*/

/*----------Folder Default Behaviour----------|START------*/
$('.big-file-manager > ul').addClass('active-folder-wrapper');
$('.big-file-manager').addClass('small');
function allStructure(newData) {
  function letGoSmallB() {
    $('.big-file-manager ul li[data-file-icon="folder"]:not(:has(ul))').addClass('empty-folder');
    $('.empty-folder').each(function () {
      $(this).find('.no-item-inside-folder').remove();
      $(this).append('<ul class="no-item-inside-folder"><span></span></ul>');
    });
    $('.big-file-manager ul li:has(ul)').addClass('has-files-of-folder');
    $('.has-files-of-folder').each(function () {
      $(this).find('.cm-folder-back').remove();
      $(this).children('b').prepend('<i title="Back" class="cm-folder-back"><i class="fas fa-angle-left"></i></i>');
    });


    //$('.big-file-manager ul > li.has-files-of-folder > b').prepend('<i title="Back" class="cm-folder-back"><i class="fas fa-angle-left"></i></i>');
  }
  if (newData == "newData") {
    letGoSmallB();
  } else {
    letGoSmallB();
  }
}
allStructure();
$(document).on('dblclick', '.big-file-manager ul li.has-files-of-folder', function (e) {
  $('.big-file-manager ul').removeClass('active-folder-wrapper');
  $(this).children('ul').addClass('active-folder-wrapper');
  $(this).siblings('li').hide();
  $(this).addClass('file-sub-active').children('ul').show();
  listfiles(this.id);
});
$(document).on('dblclick', '.big-file-manager ul li.has-files-of-folder', function (e) {
  $('.has-files-of-folder').removeClass('show-up').addClass('hide-up');
  $(this).addClass('show-up').removeClass('hide-up');
});
$(document).on('dblclick', '.big-file-manager ul li', function (e) {
  e.stopPropagation();
});
$(document).on('click', '.cm-folder-back', function (e) {
  e.stopPropagation();
  $('.big-file-manager ul').removeClass('active-folder-wrapper');
  $(this).parent('b').closest('ul').addClass('active-folder-wrapper');
  $(this).closest('.file-sub-active').siblings('li').show();
  $(this).closest('.file-sub-active').removeClass('file-sub-active');
  $(this).closest('.has-files-of-folder').find('ul').hide();
  $('.has-files-of-folder').removeClass('show-up').addClass('hide-up');
  $(this).closest('.file-sub-active').addClass('show-up').removeClass('hide-up');
  $(this).parent('b').next('ul').children('li').removeClass('select');
});
$(document).on('dblclick click', '.big-file-manager ul li,.cm-folder-back', function addtopathbar(e) {
  var text = $('.show-up[data-file-icon]').attr('data-path');
  if (text) {
    if (text.indexOf("/")) {
      $('.address-search-input').val(text);
      var getAddressData = text.toString().split('/');
      $('.address-short-btn').empty();
      for (var i = 0; i < getAddressData.length; i++) {
        $('.address-short-btn').append('<div data-address><span>' + getAddressData[i] + '</span><i class="fas fa-caret-right"></i></div>');
      }
      var getSearchPlaceholder = $('.big-file-manager.theme-structure ul > li.show-up > b').text();
      $('.files-search-input').attr('placeholder', 'Search in ' + getSearchPlaceholder);
    } else {
      $('.address-short-btn').empty();
      $('.address-short-btn').append('<div data-address><span>' + text + '</span></div>');
      $('.files-search-input').attr('placeholder', 'Search..');
    }
  } else {
    $('.address-short-btn').empty();
    $('.address-search-input').val('');
    $('.files-search-input').attr('placeholder', 'Search..');
    return false;
  }
});
/*----------Folder Default Behaviour----------|END------*/
/*---------Context Menu Start------------|START---------*/
$(document).on('contextmenu', '[data-file-icon]:not(.show-up)', function (e) {
  var off = $(this).offset();
  var topPos = e.pageY;
  var leftPos = e.pageX;
  $('.append-option-box').remove();
  $(this).addClass('context-visible').addClass('select');
  $(this).append('<div class="append-option-box" style="top:' + topPos + 'px;left:' + leftPos + 'px;"><div class="inner-contenxt-box"><div data-open="data-move">Open</div><div data-function="data-copy">Copy</div> <div data-function="data-move">Move</div> <div data-function="data-rename">Rename</div> <div data-function="data-delete">Delete</div> <div class="">Share</div> <div data-function="data-properties">Properties</div></div></div>');
  $('.append-option-box>div>div:has(div)').addClass('has-sub-context');
  if ($(this).attr('data-file-icon') != "folder") {
    $('.append-option-box .inner-contenxt-box').append('<div data-function="data-copy-path">Copy Path</div>');
    $('.append-option-box .inner-contenxt-box').append('<div data-function="data-copy-secure-path">Copy Secure Path</div>');
  }
  return false;
});
$(document).on('contextmenu', '.theme-structure', function (e) {
  var off = $(this).offset();
  var topPos = e.pageY;
  var leftPos = e.pageX;
  $('.append-option-box').remove();
  $(this).append('<div class="append-option-box" style="top:' + topPos + 'px;left:' + leftPos + 'px;"><div class="inner-contenxt-box"> <div data-function="view"> <span>View</span> <div class="main-sub-menu"> <div data-size="small">Small</div> <div data-size="medium">Medium</div> <div data-size="large">Large</div> </div> </div> <div data-function="short"> <span>Short</span> <div class="main-sub-menu"> <div>Name</div> <div>Date Modified</div> <div>Size</div> <div>Type</div> </div> </div> <div data-function="new"> <span>New Files</span> <div class="main-sub-menu"> <div>HTML File</div> <div>CSS File</div> <div>JS File</div> <div>PHP File</div> <div>Custom File</div> </div> </div> <div data-function="new-folder">New Folder</div> <div class="" data-function="paste-data">Paste</div> <div data-function="folder-properties">Properties</div> </div> </div>');
  $('.append-option-box>div>div:has(div)').addClass('has-sub-context');
  $('.has-sub-context').append('<i class="fas fa-chevron-right"></i>');
  return false;
});
$(document).on('click contextmenu dblclick', function () {
  $('[data-file-icon]').removeClass('context-visible').removeClass('select renaming');
  $('.append-option-box').remove();
  removeUnwanted();
  $('.name').attr('contenteditable', false);
});
$(document).on('click contextmenu', '.append-option-box', function (e) {
  e.stopPropagation();
  $('[data-file-icon]').removeClass('context-visible').removeClass('select');
  $('.append-option-box').remove();
});
$(document).on('click contextmenu', '[data-file-icon]', function (e) {
  e.stopPropagation();
});

function pasteData() {
  $('.data-moving').each(function () {
    if ($('.active-folder-wrapper:has(.no-item-inside-folder)')) {
      $('.active-folder-wrapper.no-item-inside-folder').children('span').remove();
      $('.active-folder-wrapper.no-item-inside-folder').removeClass('no-item-inside-folder');
      $(this).clone().removeClass('data-copy').appendTo('.active-folder-wrapper');
      $('.active-folder-wrapper').find('li').show();
      $('.data-moving,.data-copy').removeClass('data-moving').removeClass('data-copy');
      $(this).remove();
    } else {
      $(this).clone().removeClass('data-copy').appendTo('.active-folder-wrapper');
      $('.data-moving,.data-copy').removeClass('data-moving').removeClass('data-copy');
      $(this).remove();
    }
  });
  $('.data-copy').each(function () {
    if ($('.active-folder-wrapper:has(.no-item-inside-folder)')) {
      $('.active-folder-wrapper.no-item-inside-folder').children('span').remove();
      $('.active-folder-wrapper.no-item-inside-folder').removeClass('no-item-inside-folder');
      $(this).clone().removeClass('data-copy').appendTo('.active-folder-wrapper');
      $('.active-folder-wrapper').find('li').show();
      $('.data-moving,.data-copy').removeClass('data-moving').removeClass('data-copy');
    } else {
      $(this).clone().removeClass('data-copy').appendTo('.active-folder-wrapper');
      $('.data-moving,.data-copy').removeClass('data-moving').removeClass('data-copy');
    }
  });
}

function deleteData() {
  var r = confirm("Are you Sure To Delete.");
  if (r == true) {
    $('.select').remove();
    return false;
  } else {
    return false;
  }
}
function renameData(renameClass) {
  $('.renaming').removeClass('renaming');
  $(renameClass).closest('li').addClass('renaming');
  $(renameClass).closest('li').find('.name').attr('contenteditable', true).select().focus();
  $('.renaming').removeClass('select');
}
$(window).on('keydown', function (ev) {
  if (ev.keyCode === 39) { /*left arrow*/
    $('.select').next('[data-file-icon]').addClass('select').siblings().removeClass('select');
  } else if (ev.keyCode === 37) { /*right arrow*/
    $('.select').prev('[data-file-icon]').addClass('select').siblings().removeClass('select');
  } else if (ev.keyCode === 13) { /*enter*/
    $('.select:not(:last)').each(function () {
      $(this).removeClass('select');
    });
    $('.select').dblclick();
  } else if (ev.ctrlKey && ev.keyCode === 88) { /*move*/
    $('.data-moving,.data-copy').removeClass('data-moving').removeClass('data-copy');
    $('.select').addClass('data-moving').removeClass('data-copy');
    return false;
  } else if (ev.ctrlKey && ev.keyCode === 67) { /*copy*/
    $('.data-moving,.data-copy').removeClass('data-moving').removeClass('data-copy');
    $('.select').addClass('data-copy').removeClass('data-moving');
    return false;
  } else if (ev.ctrlKey && ev.keyCode === 86) { /*paste*/
    pasteData();
    createFileAndFolderDataBase();
  } else if (ev.keyCode === 46) { /*delete*/
    deleteData();
  } else if (ev.keyCode === 27 || ev.keyCode === 8) { /*Back*/
    $('.big-file-manager.theme-structure ul > li.show-up > b > .cm-folder-back').click();
  } else if (ev.ctrlKey && ev.keyCode === 65) { /*Shift Select*/

  } else if (ev.keyCode === 113) { /*Rename*/
    renameData('.select');
  }
});
/*---------Select Folder------------|START---------*/
$(document).on('click', '[data-file-icon]', function (e) {
  if (e.ctrlKey) {
    $(this).addClass('select');
    $(this).removeClass('renaming');
  } else {
    $('.select').removeClass('select');
    $(this).addClass('select').siblings().removeClass('select');
    $(this).removeClass('renaming');
  }
});
/*---------Select Folder------------|END---------*/
/*---------Open Data Context Menu------------|START---------*/
$(document).on('click', '[data-function="data-open"]', function () {
  $('.select').dblclick();
});
/*---------Open Data Context Menu------------|END---------*/
/*---------Move Data Context Menu------------|START---------*/
$(document).on('click', '[data-function="data-move"]', function () {
  $('.data-moving,.data-copy').removeClass('data-moving').removeClass('data-copy');
  $('.select').addClass('data-moving').removeClass('data-copy');
});
/*---------Move Data Context Menu------------|END---------*/
/*---------Copy Data Context Menu------------|START---------*/
$(document).on('click', '[data-function="data-copy"]', function () {
  $('.data-moving,.data-copy').removeClass('data-moving').removeClass('data-copy');
  $('.select').addClass('data-copy').removeClass('data-moving');
});
/*---------Copy Data Context Menu------------|END---------*/
/*---------Paste Data------------|START---------*/
$(document).on('click', '[data-function="paste-data"]', function () {
  pasteData();
});
/*---------Paste Data------------|END---------*/
/*---------Properties Context Menu------------|START---------*/
$(document).on('click', '[data-function="data-properties"]', function () {
  $('.cm-properties-popup-section').addClass('open');
});
$(document).on('click', '.cm-properties-close', function () {
  $('.cm-properties-popup-section').removeClass('open');
});
/*---------Properties Context Menu------------|END---------*/
/*---------Rename File and Folder------------|START---------*/
$(document).on('click', '[data-function="data-rename"]', function () {
  renameData(this);
});
/*---------Rename File and Folder------------|END---------*/
/*---------Delete File and Folder------------|START---------*/
$(document).on('click', '[data-function="data-delete"]', function () {
  deleteData();
  createFileAndFolderDataBase();
});
/*---------Delete File and Folder------------|END---------*/
/*---------Copied to Clipboard------------|START---------*/
function copyToClipboard(element) {
  var $temp = $("<input>");
  $("body").append($temp);
  var txt = '{{ ' + $(element).closest('[data-file-id]').attr('data-file-id') + ' }}';
  $temp.val(txt).select();
  document.execCommand("copy");
  $temp.remove();
  $('.theme-structure').append('<div class="copied">Copied !</div>');
  setTimeout(function () {
    $('.copied').addClass('copied-visible');
  }, 500);
  setTimeout(function () {
    $('.copied').remove();
  }, 3000);
}

function copyToClipboardPath(element) {
  var $temp = $("<input>");
  $("body").append($temp);
  var txt = $(element).closest('[data-path]').attr('data-path');
  $temp.val(txt).select();
  document.execCommand("copy");
  $temp.remove();
  $('.theme-structure').append('<div class="copied">Copied !</div>');
  setTimeout(function () {
    $('.copied').addClass('copied-visible');
  }, 500);
  setTimeout(function () {
    $('.copied').remove();
  }, 3000);
}
$(document).on('click', '[data-function="data-copy-secure-path"]', function () {
  copyToClipboard(this);
});
$(document).on('click', '[data-function="data-copy-path"]', function () {
  copyToClipboardPath(this);
});
/*---------Copied to Clipboard------------|END---------*/
/*----------Creating Path For Data------------|START----------*/
/*function getChilrenPath(path){
  var a = $(path).attr('data-slug');
  var b = $(path).closest('ul').closest('[data-slug]').attr('data-slug');
  if(typeof b === 'undefined'){
    b="";
    var c = b+"/"+a;
  }else{
    var c = "/"+b+"/"+a;
  }
  return c;
}*/
function createFileAndFolderDataBase() {
  $('.big-file-manager.theme-structure > ul li').each(function () {
    var folderSlug = $(this).children('b').not('.cm-folder-back').text().toLowerCase().split(' ').join('-');
    $(this).attr('data-slug', folderSlug);
  });
  $('[data-slug]').each(function () {
    var b = $(this).attr('data-slug');
    var a = $(this).parents('li').map(function () {
      return $(this).attr('data-slug');
    }).get().reverse().join("/");
    if (a == "") {
      $(this).attr('data-path', b);
    } else {
      $(this).attr('data-path', a + "/" + b);
    }

  });
  var folderStructureJson = [];
  $('[data-file-id]').each(function () {
    var folderStructure = {};
    var fileID = $(this).attr('data-file-id');
    var filePath = $(this).attr('data-path');
    folderStructure.fileID = "{{" + fileID + "}}";
    folderStructure.filePath = filePath;
    folderStructureJson.push(folderStructure);
  });
}
createFileAndFolderDataBase();
/*----------Creating Path For Data------------|END----------*/
/*-------Folder And Files Size-----------------------|START-------*/
$(document).on('click', '[data-size]', function () {
  var getSize = $(this).attr('data-size');
  $('.big-file-manager').removeClass('small medium large');
  $('.big-file-manager').addClass(getSize);
});
/*-------Folder And Files Size-----------------------|END-------*/
/*----------------New Folder---------------------|START------------*/
function removeUnwanted() {
  $('.active-folder-wrapper ~ .active-folder-wrapper,.active-folder-wrapper ~ .no-item-inside-folder').remove();
}

function newFolder(id, name) {
  $('.no-item-inside-folder.active-folder-wrapper').empty().removeClass('no-item-inside-folder').addClass('active-folder-wrapper');
  $(".active-folder-wrapper").append(
    '<li data-file-icon="folder" id="' +
    id +
    '" data-new="new" data-cloud="load"><b>' +
    name +
    "</b></li>"
  );
  filesAndFolderIcons("newData");
  allStructure();
  createFileAndFolderDataBase();
  $('[data-new="new"]').removeAttr("data-new");
  removeUnwanted();
}

function newFile(id, name) {
  $('.no-item-inside-folder.active-folder-wrapper').empty().removeClass('no-item-inside-folder').addClass('active-folder-wrapper');
  $(".active-folder-wrapper").append(
    '<li data-file-icon="html" ondblclick= window.open(\"' + domain + 'download/' + id + '\",\'_blank\') id="' +
    id +
    '" data-new="new" data-cloud="load"><b>' +
    name +
    "</b></li>"
  );
  filesAndFolderIcons("newData");
  allStructure();
  createFileAndFolderDataBase();
  $('[data-new="new"]').removeAttr("data-new");
  removeUnwanted();
}


$(document).on('click', '[data-function="new-folder"]', function () {
  if (document.getElementsByClassName("file-sub-active show-up")[0].id == '') {
    alert("Unknown mother folder");
    return;
  }
  let folderName = prompt("Please enter folder name", "New Folder");
  if (folderName == null || folderName == "") {
    return;
  } else {
    var newRequest = new request("createfolder");
    newRequest.xhr.onreadystatechange = function () {
      if (newRequest.xhr.readyState === 4) {
        if (newRequest.xhr.status == 200) {
          let result = JSON.parse(newRequest.xhr.responseText);
          newFolder(result.folder_id, folderName);
        }
      }
    };
    newRequest.xhr.send("folderName: " + folderName + "\nmotherID: " + document.getElementsByClassName("file-sub-active show-up")[document.getElementsByClassName("file-sub-active show-up").length - 1].id + ";");
  }
});


function uploadFile(element) {
  if (document.getElementsByClassName("file-sub-active show-up")[0].id == '') {
    alert("Unknown mother folder");
    return;
  }
  let file = element.files[0];
  var newRequest = new request("upload/" + document.getElementsByClassName("file-sub-active show-up")[document.getElementsByClassName("file-sub-active show-up").length - 1].id + "/" + file.name);
  newRequest.xhr.onreadystatechange = function () {
    if (newRequest.xhr.readyState === 4) {
      if (newRequest.xhr.status == 200) {
        let result = JSON.parse(newRequest.xhr.responseText);
        newFile(result.fileID, file.name);
      }
    }
  };
  if (file) {
    const reader = new FileReader();
    reader.onload = function (evt) {
      let contents = evt.target.result;
      let cut = contents.indexOf(";base64,"); // cut the "data:video/mp4;base64," part
      contents = contents.slice(cut + ";base64,".length);
      newRequest.xhr.send(contents);
    };
    reader.readAsDataURL(file);
  };
}

$('.address-search-input').focus(function () {
  $('.address-short-btn').hide();
  $(this).select();
}).blur(function () {
  $('.address-short-btn').show();
});


$(document).on('click', '[data-function="create-group"]', function () {
  let groupName = prompt("Please enter folder name", "New Folder");
  if (groupName == null || groupName == "") {
    return;
  } else {
    var newRequest = new request("creategroup");
    newRequest.xhr.onreadystatechange = function () {
      if (newRequest.xhr.readyState === 4) {
        if (newRequest.xhr.status == 200) {
          let result = JSON.parse(newRequest.xhr.responseText);
          add_group("ownedgroups", result.group_id, result.group_folder_id, groupName)
        }
      }
    };
    // console.log(data);
    newRequest.xhr.send("groupName: " + groupName + ";");
  }
});

function join_group() {
  let groupID = document.getElementById("joingroupID").value;
  var newRequest = new request("joingroup");
  console.log(groupID);

  newRequest.xhr.onreadystatechange = function () {
    if (newRequest.xhr.readyState === 4) {
      if (newRequest.xhr.status == 200) {
        let result = JSON.parse(newRequest.xhr.responseText);
        console.log(result + result.gid);
        add_group("joinedgroups", result.gid, result.id, result.name);
        document.getElementById("joingroupID").value = "";
      }
    }
  }
  newRequest.xhr.send("groupID: " + groupID + ";");
};

$('.address-search-input').focus(function () {
  $('.address-short-btn').hide();
  $(this).select();
}).blur(function () {
  $('.address-short-btn').show();
});
/*$(document).on('click','.address-button',function() {
  var getAddressInput = $('.address-search-input').val().toString().trim();
  $('[data-path]').removeClass('show-up');
  $('[data-path="'+getAddressInput+'"]').addClass('show-up');
  $('.big-file-manager.theme-structure ul').removeClass('active-folder-wrapper');
  $(this).children('ul').addClass('active-folder-wrapper');
});*/
/*----------------New Folder---------------------|START------------*/


function listfiles(folderID) {
  var newRequest = new request("listfiles");
  newRequest.xhr.onreadystatechange = function () {
    if (newRequest.xhr.readyState === 4) {
      if (newRequest.xhr.status == 200) {
        let result = JSON.parse(newRequest.xhr.responseText);
        result.forEach(element => {
          if (document.getElementById(element.id) == null) {
            if (element.type == "DIR") {
              newFolder(element.id, element.name);
            }
            else if (element.type == "FILE") {
              newFile(element.id, element.name);
            }
          }
        });
      }
    }
  };
  newRequest.xhr.send("folderID: " + folderID + ";");
}