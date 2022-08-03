# GM Pointclouds

Proof of concept for real-time point cloud visualisations of Garry's Mod maps. Still *extremely* work-in-progress, but the core concepts are there and it's working well enough!

![image](https://user-images.githubusercontent.com/6502927/182530756-0b52de70-c493-4e04-a213-35dce25cd742.png)


## Addon Installation

Copy the *gmod_pointcloud_scanner* directory into your Garry's Mod addons folder. The Pointcloud scanner weapon can then be found in the spawnmenu.

When you load into a game, you will need to specify the callback URL for the scanner to function.

```bash
pointcloud_url "http://pointcloud.example.com"
```

## Webserver

Note that Garry's Mod cannot send HTTP requests to a local network addresses. If you're running this server locally, you'll probably want to expose this publically. I recommend [localtunnel](https://github.com/localtunnel/localtunnel).

The webserver is a simple Express application. Run `node server.js`. By default, it listens on port 3000.

### Docker

The webserver can also be run with Docker, if you're into that:

```bash
cd webserver
docker build . rafraser/pointcloud-server 
docker run -p 3000:3000 rafraser/pointcloud-server
```
