# GM Pointclouds

## Addon Installation

Copy the *gmod_pointcloud_scanner* directory into your Garry's Mod addons folder. The Pointcloud scanner weapon can then be found in the spawnmenu.

## Webserver

Note that Garry's Mod cannot send HTTP requests to a local network addresses. If you're running this server locally, you'll probably want to expose this publically. I recommend [localtunnel](https://github.com/localtunnel/localtunnel).

### Docker

```bash
cd webserver
docker build . rafraser/pointcloud-server 
docker run -p 3000:3000 rafraser/pointcloud-server
```
