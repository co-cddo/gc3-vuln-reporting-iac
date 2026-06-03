const backButtons = document.getElementsByClassName('back-button');

if (backButtons.length > 0) {
  var element = backButtons[0];
  element.setAttribute('href', document.referrer);
  element.onclick = function() {
    history.back();
    return false;
  }
}

var emails = document.getElementsByClassName('email');
for (var i = 0; i < emails.length; i++) {
  var email = emails[i].innerText.replace("[at]", "@");
  emails[i].innerHTML = '<a class="govuk-link" href="mailto:'+ email +'">'+ email +"</a>";
}


const embedHackerOneForm = function(orgUuid) {
  const pleaseWait = document.createElement('p');
  pleaseWait.classList.add('govuk-body');
  pleaseWait.textContent = 'Please wait';
  setTimeout(() => { pleaseWait.textContent = '' }, 8000);
  document.getElementById('hackerone-form-container').replaceChildren(pleaseWait);

  const script = document.createElement('script');
  script.src = `https://hackerone.com/${orgUuid}/embedded_submissions/script`;
  script.async = true;
  script.type = 'text/javascript';
  Object.assign(script.dataset, {
    url: `https://hackerone.com/${orgUuid}/embedded_submissions/new?locale=en`,
    name: 'h1-embedded-submission'
  });
  document.getElementById('hackerone-form-container').appendChild(script);
};


document.querySelector('#organisation-select')?.addEventListener('change', e => {
  const orgUuid = e.target.value;

  // Safari doesn't allow iframes to set cookies, so in that case we redirect instead
  // To identify "true" Safari, we must check for the presence of the string 'Safari' while
  // simultaneously ensuring the absence of 'Chrome' or 'Chromium'.
  const isSafari = /^((?!chrome|android).)*safari/i.test(navigator.userAgent);
  if (isSafari) {
    window.location.href = `https://hackerone.com/${orgUuid}/embedded_submissions/new?locale=en`;
  } else {
    embedHackerOneForm(orgUuid);
  }
});
