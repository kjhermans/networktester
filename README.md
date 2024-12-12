# networktester
Scripts to automate tests of network functionality.

# Introduction

This tooling is subdivided into two utilities: one to set up your
network (or tear it down), and one to run inside the network's various
nodes. Both use the same (JSON structured) definition, allowing you
to make changes to your setup in one convenient place.

The project is coded in Perl, but uses no modules on top of what is
usually already installed on a Linux system. In other words, you
should be able to just run them on an average major distro box.
Just chmod the scripts to 0755 (or something).

# Example to get you going

Typically, a test is run as follows (as root):

    # ./network.pl mydefinition.json off # To make sure the network is off.
    # ./network.pl mydefinition.json on  # Now it's on again.
    # ./tester.pl mydefinition.json      # A clock will run all the tests.

The last invocation will block until the defined period of testing
has run out.

Example of a test definition (untested):

    {
      "duration" : 30,
      "env" : { "FOO" : "BAR" },
      "nodes" : {
        "client" : {
          "interfaces" : {
            "eth0" : {
              "connection" : { "node" : "server", "interface" : "eth0" },
              "ip" : "192.168.1.20/24"
            }
          },
          "tests" : [
            {
              "cwd" : "/etc",
              "executable" : "nc 192.168.1.21 5000 < ./passwd",
              "start" : 2,
              "duration" : 5
            }
          ]
        },
        "server" : {
          "interfaces" : {
            "eth0" : {
              "connection" : { "node" : "client", "interface" : "eth0" },
              "ip" : "192.168.1.21/24"
            }
          },
          "tests" : [
            {
              "d" : "/tmp/",
              "e" : "nc -l -p 5000 >/tmp/stolenpasswd",
              "s" : 1
            },
            {
              "d" : "/tmp/",
              "e" : "tcpdump -l -n -i servereth0",
              "s" : 1
            }
          ]
        }
      },
      "prepare" : "./prepare.sh",
      "success" : "./success.sh",
      "finish" : "./finish.sh"
    }

Note the following:

- Network interfaces will be the concatination of the
  node name, plus the interface definition name.
- Inside a test definition, we can:
  - Specify a command line execution.
  - A working directory as a context for that execution.
  - A set of environment variables as a context for that execution.
  - A start time (in seconds).
  - A duration (in seconds), or leave it to signify 'this test will run
    until the end'.
- There is a short and long form for those definitions.
- You can define environment variables for all tests.
- You can define a script that will be run previous to any tests.
- You can define a script that will be run after all the tests
  (well, after the clock has run out).
- You can define a script that will defined whether or not the
  test as a whole was a success or not.
- You can define switches as anonymous L2 devices to create more
  complicated network setups.
- You can define routers as non anonymous L3 devices to create more
  complicated network setups.

# How to Create Switches / Routers

How to create a router. Don't forget that routers are L3 devices
and need IP addresses. Look up for inspiration on that.

    "nodes" : {
      "foo" : {
        "type" : "router",
        "interfaces" : {
          "eth0" : { /* Needs IP config */ },
          "eth1" : { /* Needs IP config */ }
        }
      }
    }

How to create a switch. In this case, the curly braces of an
interface definition can / should probably remain empty.

    "nodes" : {
      "foo" : {
        "type" : "switch",
        "interfaces" : {
          "eth0" : { },
          "eth1" : { },
          "eth2" : { },
          "eth3" : { }
        }
      }
    }

# How we Determine when the Clock Runs Out

Every test contains a start time (or defaults at zero), and has a
duration (or defaults as infinite). The maxmimum is taken from all 
start times plus their respective durations, and this is determined
to be the length of the test. If this is infinite, it will look for
any "duration" key at the top of the structure and if present, will
take that time. Otherwise, the thing runs indefinitely. All time
indications are in whole seconds.


