# masjidSignin

QR Code signin for masjid. Needed for COVID-19-related contact tracing

# What _is_ this repo?

As Director of Security at my local masjid (mosque), I wanted a quick, secure, and reliable way to sign people in as they enter the building. I wanted their name, phone number, and optionally their email address. This is so that if anyone attending services tested positive for COVID-19 and informed us, we can let everyone else who attended around that time know about it (by phone and email) so that they can get themselves tested. 

The companion [backend repo][backend] allows people to visit a website before attending. They can enter their name, phone number, and email on a form. When they submit the form, the website will generate an image containing a QR Code that contains that information. Then they can save that image on their phone. 

This repo contains an iOS client app for volunteers to help people signin.  The people at the masjid signing folks in can scan the QR code using those apps. Once a QR code is signed, the mobile client will contact the REST web server described and this repo, and the web server will save the data into the database. More information on how to use the apps will be available soon.

[backend]: https://github.com/aijaz/qrCodeSigninServer
