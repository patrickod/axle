# axle

An effortless HTTP reverse proxy for node

## Installation
```
npm install -g axle
```

## Usage

Run the axle server.  This should run on the port you want all your web traffic to pass through.

```bash
$ PORT=8000 axle
```

or

```bash
$ sudo PORT=80 axle
```

Then run your node servers the way you usually would, but with `axle` before them.

```bash
$ axle caboose server
```

To specify a domain or multiple domains you would like to route to this server, use the `AXLE_DOMAINS` environment variable.
This is a comma separated list of domains.


```bash
$ AXLE_DOMAINS=*.mattinsler.com,code.mattinsler.dev axle caboose server
```

You can also specificy a list of domains for axle to route to this server by adding them to the package.json of the application which which you are currently working. For example:

```json
  "axle_domains": ["*.mattinsler.com", "code.mattinsler.dev"]
```

## License
Copyright (c) 2012 Matt Insler
Licensed under the MIT license.
