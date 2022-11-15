## Setting up our Nodejs app using only the Ansible controller VM

First, create a yml playbook to install nodejs on the web VM
```

```

Next, do the same but this time for npm

```

```

Go back to your localhost and scp the app folder to controller VM

```

```

Then make a third playbook, this one should copy the app folder from controller to web

```

```

Run the adhoc command for ls - to list the files available to web:

```

```

Now make a fourth playbook. This one should cd into the folder and start the app

```

```

Screenshot of output


Finally, check the web ip on port 3000 (192.168.33.10:3000). The sparta test app should be running and viewable.

Screenshot of browser