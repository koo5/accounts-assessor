# getting started with Robust, in Excel
After installing LSU, first thing is to select the right Robust server:
![screenshot](https://raw.githubusercontent.com/koo5/accounts-assessor-public-wiki//20210903004539.png)
The server probably requires authentication:
![screenshot](20210903004550.png)
![screenshot](20210903004607.png)
Enter your credentials, joined by a `:`, like this: `username:password`.

It's also a good idea to update template data, unless you only want to run requests on existing excel files:
![screenshot](20210903004618.png)
 Note: unfortunately, it's not persistent yet, so you'll need to do it again if you close Excel.

![screenshot](20210903004635.png)
Yay!

Finally, we can load an example:
![screenshot](20210903004646.png)
 This one contains a medium-sized set of example bank statements and some other data.


Now it's time to ask the server to process it:
![screenshot](20210903005405.png)

Excel will wait a while and then give up, because this example keeps the server busy for anywhere between 3 and 10 minutes. But this is not a problem.
![screenshot](20210903005521.png)


A browser window opens automatically:
![screenshot](20210903010716.png)
 Wait a few minutes and hit F5 until `completed` appears. There will eventually be a way to manage long-running requests better :-)

![screenshot](20210903010732.png)
 This is a directory where all reports, as well as various machine-readable files, are saved. You should always check the alerts file. If any issues were detected, they will be noted here. In this case, it says `no alerts.`, so we move on.

![screenshot](20210903010743.png)
Good.

![screenshot](20210903011009.png)
Back in Excel, we can now load any result sheets produced:

![screenshot](20210903011026.png)
This is the excel version of the investment report, that you can also find among the html files. Nice!


