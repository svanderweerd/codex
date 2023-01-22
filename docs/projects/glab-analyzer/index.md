A `pyhon` project that focuses on the extraction and analyses of the Gitlab events.

# Setup

The setup of the project is as follows:

* Consumes Gitlab built-in API
* Fetches - on glab project basis - the MR's, Push events
* Determine unreviewed MRs and direct push to release branches
* Outputs Excel file with the results

## 3rd party libs used

The following libraries are used:

* `glab` == Gitlab's python library
* `pandas` == For analyzing data and building Excels
* `jira` == for searching and pushing excels to Jira issues

# Documentation

* Gitlab API docs
