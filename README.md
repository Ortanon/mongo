# Alpine Mongo
Docker Official doesn't maintain an Alpine-based MongoDB image. I'm sure they have their reasons. My use cases haven't seemed to need Ubuntu so far.

## Getting started

0. Install [Docker](https://www.docker.com/products/docker-desktop).
0. Pull this image.

	$ docker pull karimtemple/mongo

## Getting busy

Just some quick notes on how I'm currently using containerized Mongo:

### Setup

MongoDB's workflow, syntax, and documentation are all kind of a pain in the ass for a beginner like me. Here's where I've come down on the subject of first steps:

**Storage**

Set up a Docker volume to let docker virtualize the storage for MongoDB. The defaults work fine. The example volume name here is "mongofiles":

	$ docker volume create mongofiles

**Admin**

The image's CMD is using the `--auth` flag by default, but Docker lets you override CMD commands. Just `docker run` with `--noauth` at first to set up admin:

	$ docker run --name db -d -v mongofiles:/data/db karimtemple/mongo mongod --bind_ip_all --noauth
	$ docker exec -it db mongo
	> use admin
	> db.createUser({ user: "whatever", pwd: "something", roles: [{role: "readWrite" db: "example"}], mechanisms: ["SCRAM-SHA-1"] })
	$ docker stop db

### Development

You can run the MongoDB container like a service now and use it in your app:

	$ docker run --name db -d -v devdata:/data/db --restart=unless-stopped karimtemple/mongo

Of course, you can use something like `-i` instead of `-d` to watch the mongod output.

**Connections**

Add `-p 27017:27017` if you want to use Mongo clients in your host OS, but it's not necessary. Apps in containers can use Docker networking to get at it. Just use the IP:

	$ docker inspect -f={{.NetworkSettings.IPAddress}} db

Then you can get real fancy in your app container like:

	$ docker run --name exampleapp -a stdout -a stderr -p 3000:3000 -e "MONGODB_URL=mongodb://testuser:password@172.17.0.2:27017/?authSource=admin" exampleimage:latest

If you're using NodeJS, you can have a container run your local code, e.g.:

	$ docker run --rm --name app -v "$PWD":/app -w /app -p 3000:3000 -i -e "MONGODB_URL=mongodb://testuser:password@172.17.0.2:27017/?authSource=admin" node:alpine npm start