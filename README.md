# Temporary Passwords

This mod handles temporary passwords; players logging in with a temporary password are prompted to change their password to activate their account. Players with the privileges to use the `/setpassword` command, usually those with the `password` privilege, can change others' passwords to a temporary one via the `/temp_password <username>` command. New accounts can also be created like this, just like how `/setpassword` implements the function of creating an account.

After creating a temporary account, information will be shown to the operator for them to send to the player via other means, e.g. instant messaging apps. If the player is online (i.e. not issuing the command via IRC or Discord relay), a GUI is also shown with that information for easier copying.

Note that the temporary passwords are sent in plain text. If that is a concern, do not use this mod, and do password changes via a secure method (e.g. SSH with specialized mods).

In addition to temporary passwords, default passwords (set by `default_password` and handled by the engine) are also treated as temporary passwords. Therefore, users logging in with that password must change their password after logging in.
