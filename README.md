# networktester
Scripts to automate tests of network functionality.

This tooling is subdivided into two utilities: one to set up your
network (or tear it down), and one to run inside the network's various
nodes. Both use the same (JSON structured) definition.

The project is coded in Perl, but uses no modules on top of what is
usually already installed on a Linux system.

Typically, a test is run as follows:

    ./network.pl mydefinition.json off # To make sure the network is off.
    ./network.pl mydefinition.json on  # Now it's on again.
    ./tester.pl mydefinition.json

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
              "executable" : "nc 192.168.1.21 5000 < /etc/passwd",
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

