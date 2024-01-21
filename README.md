# ℹ️ Richy-Z/lua-edulink
[![🌤️ Publish package to lit](https://github.com/Richy-Z/lua-edulink/actions/workflows/publish-to-lit.yml/badge.svg)](https://github.com/Richy-Z/lua-edulink/actions/workflows/publish-to-lit.yml)

## 👋🏻 Whats this?
`Richy-Z/lua-edulink` is a Lit package that provides seamless integration between the EduLink One API and Luvit.

> Edulink One is a whole school solution designed for teachers, parents and students to effectively collaborate in a user-friendly mobile and web app.

The EduLink One API is completely proprietary and undocumented (at least publically) so this required some reverse engineering.

Please note that this is **NOT** a full-fledged integration of the EduLink API. This library is incredibly limited and does not provide certain API calls such as teacher ones. **Only the student calls have been implemented.**

## 📥 Installation
Firstly, ensure that luvit is installed fully. If not, visit [the installation page](https://luvit.io/install.html).

Type the following into your terminal to install the `lua-edulink` package:
```bash
lit install Richy-Z/lua-edulink
```
Now you have `lua-edulink` installed!

## 🔨 Usage
As with any other package, you have to require `lua-edulink`. Additionally, since you're interacting with an API, you will have to authenticate with valid **STUDENT** credentials.

```lua
local edulink = require("lua-edulink") -- requires the package

edulink.authenticate("student@school.org", "password", "school postcode") -- logs in with the credentials
```

## ⚠️ Disclaimer
This package is the result of ***reverse engineering*** efforts...

... to understand the communication protocol between the client application and the EduLink One API. The EduLink One API is proprietary and currently undocumented (at least publicly). Whilst the intention behind this package is to facilitate seamless integration with Luvit and to explore for educational purposes how certain applications are built, it's important to be aware of potential legal implications.

This Lit package is to be ***used at your own risk***.

I, the author, its contributors, and maintainers are not responsible for any actions, legal consequences, or issues that may arise as a result of using this package. Users are advised to review the Terms of Service and licensing agreements of EduLink One before incorporating this package into proper production projects.

----------------------------------------------------------------------------------------------------

I would also like to note that ***unauthorised access of school systems can become problematic.*** School systems are sometimes built so horribly that even you with your student credentials could probably access some teacher only API calls and break the whole system. It is recommended to just stay within your student boundaries if you want to avoid wasting your time trying to explain to your 60 year old math teacher what the internet is. Even if you're correct, school systems just work in the teachers favor and you will get a detention or isolation or any punishment regardless.