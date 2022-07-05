var element = document.getElementsByClassName('back-button')[0];
element.setAttribute('href', document.referrer);
element.onclick = function() {
  history.back();
  return false;
}

var emails = document.getElementsByClassName('email');
for (var i = 0; i < emails.length; i++) {
  var email = emails[i].innerText.replace("[at]", "@");
  emails[i].innerHTML = '<a href="mailto:'+ email +'">'+ email +"</a>";
}

function hackerone_onerror() {
  display_secondary();
}

function display_secondary() {
  document.getElementById("submit-default-form").classList.add("hidden");
  document.getElementById("submit-secondary-form").classList.remove("hidden");
}
