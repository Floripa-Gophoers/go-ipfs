package unixfs

import cmds "github.com/ipfs/go-ipfs/commands"

var UnixFSCmd = &cmds.Command{
	Helptext: cmds.HelpText{
		Tagline: "Interact with ipfs objects representing Unix filesystems.",
		ShortDescription: `
'ipfs file' provides a familiar interface to file systems represented
by IPFS objects, which hides IPFS implementation details like layout
objects (e.g. fanout and chunking).
`,
		Synopsis: `
ipfs file ls <path>...  - List directory contents for <path>...
`,
	},

	Subcommands: map[string]*cmds.Command{
		"ls": LsCmd,
	},
}
