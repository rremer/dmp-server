dmp-server
==============

Deployment scripts for a Kerbal Space Program [Dark Multiplayer] server.

The Dockerfile was just for iterating over the discovery process of build dependencies (docker's build cache is pretty nice for this). If you want to build a real image, use:
```packer build -only=amazon-ebs packer.json```

You'll probably want a terraform template which builds the IAM policy for your s3 backup user and provisions the bucket and security group.


[Dark Multiplayer]:https://github.com/godarklight/DarkMultiPlayer
