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
  submit_display_secondary();
}

function submit_display_default_form() {
  document.getElementById("submit-loading").classList.add("hidden");
  document.getElementById("submit-default-form").classList.remove("hidden");
  document.getElementById("submit-secondary-form").classList.add("hidden");
}

function submit_display_secondary() {
  document.getElementById("submit-loading").classList.add("hidden");
  document.getElementById("submit-default-form").classList.add("hidden");
  document.getElementById("submit-secondary-form").classList.remove("hidden");
}

var submit_iframe_check;
var submit_iframe_interval = 1500;

function hackerone_check_form() {
  document.getElementById("submit-loading").classList.remove("hidden");
  submit_iframe_check = setInterval(function() {
    var load_secondary = true;
    var iframes = document.getElementsByTagName("iframe");
    if (iframes.length == 1) {
      try {
        if (parseInt(iframes[0].style.height.replace("px", "")) > 1000) {
          load_secondary = false;
          clearInterval(submit_iframe_check);
        }
      } catch (e) {
        console.log("hackerone_check_form", e);
      }
    }
    if (load_secondary) {
      submit_display_secondary();
    } else {
      submit_display_default_form();
    }
    submit_iframe_interval = 500;
  }, submit_iframe_interval);
}
