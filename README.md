# 👤 info_user.sh

A **Bash script** for retrieving detailed information about system users, groups, and recent logins. It also provides disk usage stats and writes output logs to `/var/log/info_user.log`.

## 🧰 Features

- 📄 Display information about a specific user:
  - Login status (connected/disconnected)
  - Last remote and local login attempts
  - Groups the user belongs to
  - Files >1MB in the home directory
  - Total space used by the home folder
- 👥 Display users in a specific group
- 🔐 Show the 5 most recent local and remote login attempts
- 🆘 Help message for usage assistance
- 📝 Logs output to `/var/log/info_user.log`
- 🛑 Robust error handling
