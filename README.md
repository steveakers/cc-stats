### NAME

**cc-stats** - pulls a large dataset from graphite by making multiple requests then calculates the mean and standard deviation

###SYNOPSIS

**cc-stats** [options] \<metric_name>

###DESCRIPTION

**cc-stats** is a VERY special purpose command line tool to calculate mean and standard deviation from a dataset pulled from
Graphite. For example, if you wanted to create a 1 hour control chart monitor using rearview you'd need a mean and standard
deviation that was calculated using the same lowess smoothing parameters used in the control chart itself. This tool allows
you to do that over a larger timeframe. It also allows you to specify a time range when operations are 'shutdown' (e.g. do
not use data between midnight and 8am.)

###OPTIONS

**cc-stats**'s default mode is to pull the last days worth of data in 1 hour buckets from a local Graphite instance.

These options can be used to change this behavior:

**-g, --graphite <s>**<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Graphite URI (default: http://localhost:2300)

**-v, --verbose**<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Enable verbose output

**-b, --begin**<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Begin date in epoch time

**-e, --end**<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;End date in epoch time

**-h, --hour_stop**<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Hour when operations stop (default: 0)

**-d, --duration**<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Duraiton of shutdown (default: 0)

**-i, --interval**<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Interval in minutes (default: 60)

You may additional check the version or ask for help:

**-e, --version**<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Print version and exit

**-l, --help**<br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Print help and exit